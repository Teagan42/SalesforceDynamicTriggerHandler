public class AccountTriggerHandler
{
    public override void beforeInsert(List<SObjects> newObjects)
    {
        List<Account> accounts = new List<Account>(newObjects);

        for (Account account : accounts)
        {
            account.Name = account.Name + ' Before Insert!';
        }
    }
}