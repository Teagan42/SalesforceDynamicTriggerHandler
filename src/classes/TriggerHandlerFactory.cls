public with sharing abstract class TriggerHandlerFactory
{
    private static final List<String> namespaces = new List<String>();
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

            for (String namespace : namespaces)
            {
                try
                {
                    if (String.isBlank(namespace))
                    {
                        handle(handlerName);
                    }
                    else
                    {
                        handle(namespace, handlerName);
                    }

                    return;
                }
                catch (TriggerHandlerException e)
                {
                    System.debug(e.getMessage());
                }
            }
        }
    }

    public static void handle(String handlerName)
    {
        TriggerHandler handler = (TriggerHandler)Type.forName(handlerName).newInstance();

        handle(handler);
    }

    public static void handle(String namespace, String handlerName)
    {
        TriggerHandler handler = (TriggerHandler)Type.forName(namespace, handlerName).newInstance();

        handle(handler);
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