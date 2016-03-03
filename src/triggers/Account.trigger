trigger Account on Account (after insert)
{
    TriggerHandlerFactory.handle();
}