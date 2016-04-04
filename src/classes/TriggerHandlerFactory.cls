public with sharing abstract class TriggerHandlerFactory
{
    private static final List<String> namespaces = new List<String>();
    private static final List<TriggerHandlerPreprocessor__c> preprocessors = [
            SELECT Class_Name__c
                 , Namespace__c
            FROM TriggerHandlerPreprocessor__c
        ];
    private static final List<String> handlerNamePatterns = new List<String>
        {
            '{0}TriggerHandler'
          , '{0}Handler'
        };

    public static void addNamespace(String namespace)
    {
        namespaces.add(namespace);
    }

    public static void addHandlerNamePattern(String handlerNamePattern)
    {
        handlerNamePatterns.add(handlerNamePattern);
    }

    private static List<ITriggerHandlerPreProcessor> getPreProcessors()
    {
        List<ITriggerHandlerPreProcessor> result = new List<ITriggerHandlerPreProcessor>();

        for (TriggerHandlerPreprocessor__c preprocessor : preprocessors)
        {
            try
            {
                Type preprocessorType;
                if (!String.isBlank(preprocessor.Namespace__c))
                {
                    preprocessorType = Type.forName(preprocessor.Namespace__c, preprocessor.Class_Name__c);
                }
                else
                {
                    preprocessorType = Type.forName(preprocessor.Class_Name__c);
                }

                if (preprocessorType == null)
                {
                    continue;
                }


                ITriggerHandlerPreProcessor preprocessorHandler = (ITriggerHandlerPreProcessor)preprocessorType.newInstance();

                result.add(preprocessorHandler);
            }
            catch (Exception e)
            {
                System.debug('Unable to create preprocessor: ' + preprocessor.Class_Name__c);
                System.debug(e.getMessage());
            }
        }

        return result;
    }

    private static void preprocess()
    {
        List<ITriggerHandlerPreProcessor> preprocessorHandlers = getPreProcessors();

        for (ITriggerHandlerPreProcessor preprocessorHandler : preprocessorHandlers)
        {
            preprocessorHandler.preprocess();
        }
    }

    public static void handle()
    {
        if (!Trigger.isExecuting)
        {
            return;
        }

        SObjectType objectType;

        if (Trigger.isDelete)
        {
            objectType = Trigger.old[0].getSObjectType();
        }
        else
        {
            objectType = Trigger.new[0].getSObjectType();
        }

        handle(objectType);
    }

    public static void handle(SObjectType objectType)
    {
        String objectName = objectType.getDescribe().getName();

        for (String handlerNamePattern : handlerNamePatterns)
        {
            String handlerName = String.format(handlerNamePattern, new List<String> { objectName });

            try
            {
                if (namespaces.isEmpty())
                {
                    if (handle(handlerName))
                    {
                        return;
                    }
                }
                else
                {
                    for (String namespace : namespaces)
                    {
                        if (String.isBlank(namespace))
                        {
                            if (handle(handlerName))
                            {
                                return;
                            }
                        }
                        else
                        {
                            if (handle(namespace, handlerName))
                            {
                                return;
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                System.debug(e.getMessage());
            }
        }
    }

    public static Boolean handle(String handlerName)
    {
        return handle(Type.forName(handlerName));
    }

    public static Boolean handle(String namespace, String handlerName)
    {
        return handle(Type.forName(namespace, handlerName));
    }

    private static Boolean handle(Type handlerType)
    {
        if (handlerType == null)
        {
            return false;
        }

        TriggerHandler handler = (TriggerHandler)handlerType.newInstance();

        handle(handler);

        return true;
    }

    private static void handle(TriggerHandler handler)
    {
        if (handler == null)
        {
            throw new TriggerHandlerException('No trigger handler found for: ' + namespace + '.' + handlerName);
        }

        handler.execute();
    }
}