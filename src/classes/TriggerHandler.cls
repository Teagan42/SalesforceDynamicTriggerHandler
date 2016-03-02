public abstract class TriggerHandler
{
    public TriggerHandler()
    {

    }

    public void execute()
    {
        TriggerHandlerExecution__c executionControl = getTriggerExecutionControl();

        if (Trigger.isBefore)
        {
            if (Trigger.isInsert && executionControl.Insert__c)
            {
                handleBeforeInsert(Trigger.new);
            }
            else if (Trigger.isUpdate && executionControl.Update__c)
            {
                handleBeforeUpdate(Trigger.oldMap, Trigger.newMap);
            }
            else if (Trigger.isDelete && executionControl.Delete__c)
            {
                handleBeforeDelete(Trigger.old);
            }
            else if (Trigger.isUndelete && executionControl.Undelete__c)
            {
                handleBeforeUndelete(Trigger.new);
            }
        }
        else if (Trigger.isAfter)
        {
            if (Trigger.isInsert && executionControl.Insert__c)
            {
                handleAfterInsert(Trigger.new);
            }
            else if (Trigger.isUpdate && executionControl.Update__c)
            {
                handleAfterUpdate(Trigger.oldMap, Trigger.newMap);
            }
            else if (Trigger.isDelete && executionControl.Delete__c)
            {
                handleAfterDelete(Trigger.old);
            }
            else if (Trigger.isUndelete && executionControl.Undelete__c)
            {
                handleAfterUndelete(Trigger.new);
            }
        }

        andFinally();
    }

    private TriggerHandlerExecution__c getTriggerExecutionControl()
    {
        SObjectType objectType;

        if (Trigger.isDelete)
        {
            objectType = Trigger.old[0].getSObjectType();
        }
        else
        {
            objectType = Trigger.new[0].getSObjectType();
        }

        String objectName = objectType.getDescribe().getName();
        TriggerHandlerExecution__c executionControl = TriggerHandlerExecution__c.getInstance(objectName);

        if (executionControl == null)
        {
            executionControl = new TriggerHandlerExecution__c(Name = objectName);
        }

        return executionControl;
    }

    public virtual void handleBeforeInsert(List<SObject> newObjects)
    {

    }

    public virtual void handleAfterInsert(List<SObject> newObjects)
    {

    }

    public virtual void handleBeforeUpdate(Map<Id, SObject> oldObjectMap, Map<Id, SObject> newObjectMap)
    {

    }

    public virtual void handleAfterUpdate(Map<Id, SObject> oldObjectMap, Map<Id, SObject> newObjectMap)
    {

    }

    public virtual void handleBeforeDelete(List<SObject> oldObjects)
    {

    }

    public virtual void handleAfterDelete(List<SObject> oldObjects)
    {

    }

    public virtual void handleBeforeUndelete(List<SObject> newObjects)
    {

    }

    public virtual void handleAfterUndelete(List<SObject> newObjects)
    {

    }

    public virtual void andFinally()
    {

    }
}