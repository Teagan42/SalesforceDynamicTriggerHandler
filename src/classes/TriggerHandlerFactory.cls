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