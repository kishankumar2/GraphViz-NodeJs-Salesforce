/**
 * @description       : 
 * @author            : Kishan Kumar
 * @group             : 
/**
 * @description       : This class provides methods to get the subordinates of a manager, and to get a map of accounts with their related opportunities, contacts, and cases.
 * @last modified on  : 06-04-2023
 * @last modified by  : Kishan Kumar
**/
public class RoleHierarchy {
    // Map to store subordinates by manager
    Public static Map<String, List<String>> subordinatesByManager = new Map<String, List<String>>();
    // String to store the value of the keys map
    public static String value='';
    
    /**
     * @description       : This method returns a map of subordinates by manager.
     * @param             : None
     * @return            : Map<String, List<String>> - Map of subordinates by manager
    **/
    public static Map<String, List<String>> getSubordinatesByManagerMap() {
        // Query all user roles and store them in a map
        Map<Id, UserRole> roleMap = new Map<Id, UserRole>([SELECT Id, Name, ParentRoleId FROM UserRole]);
        // Loop through each role and add its subordinates to the map
        for (UserRole role : roleMap.values()) {
            if (role.ParentRoleId != null) {
                String manager = roleMap.get(role.ParentRoleId).Name;
                if (!subordinatesByManager.containsKey(manager)) {
                    subordinatesByManager.put(manager, new List<String>());
                }
                subordinatesByManager.get(manager).add(role.Name);
            }
        }
        return subordinatesByManager;
    }
    
    /**
     * @description       : This method returns a map of accounts with their related opportunities, contacts, and cases.
     * @param             : String AccId - The ID of the account to get the map for
     * @return            : Map<String, List<String>> - Map of accounts with their related opportunities, contacts, and cases
    **/
    public static Map<String, List<String>> getAccountMap(String AccId) {
        // Query the account and its related opportunities and contacts
        Account Acc = [Select Id , Name,(Select Id,Name from Opportunities),(Select Id , Name from Contacts) from Account where id = :AccId];
        // Set to store the IDs of the related opportunities
        Set<ID> oppIds = new SET<ID>();
        // Set to store the IDs of the related contacts
        Set<ID> conIds = new SET<ID>();
        // Loop through each related opportunity and add it to the map
        for(Opportunity op:Acc.Opportunities){
            value=value+''+Acc.Name+' -> '+op.Name+';';
            if (!subordinatesByManager.containsKey(Acc.Name)) {
                subordinatesByManager.put(Acc.Name, new List<String>());
            }
            subordinatesByManager.get(Acc.Name).add(op.Name);
            oppIds.add(op.id);
        }
        // Loop through each related contact and add it to the map
        for(Contact op:Acc.Contacts){
            if (!subordinatesByManager.containsKey(Acc.Name)) {
                subordinatesByManager.put(Acc.Name, new List<String>());
            }
            subordinatesByManager.get(Acc.Name).add(op.Name);
            conIds.add(op.id);
        }
        // Loop through each related opportunity line item and add it to the map
        for(OpportunityLineItem od:[select id,Product2.Name,Opportunity.Name from OpportunityLineItem where OpportunityId in :oppIds ]){
            if (!subordinatesByManager.containsKey(od.Opportunity.Name)) {
                subordinatesByManager.put(od.Opportunity.Name, new List<String>());
            }
            subordinatesByManager.get(od.Opportunity.Name).add(od.Product2.Name);
        }
        // Loop through each related case and add it to the map
        for(Case ca:[select id,caseNumber,Contact.Name from Case where contactId in :conIds ]){
            if (!subordinatesByManager.containsKey(ca.Contact.Name)) {
                subordinatesByManager.put(ca.Contact.Name, new List<String>());
            }
            subordinatesByManager.get(ca.Contact.Name).add(ca.caseNumber);
        }
        return subordinatesByManager;
    }
}
