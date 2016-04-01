trigger Account on Account (after insert, before insert)
{
    TriggerHandlerFactory.handle();
}