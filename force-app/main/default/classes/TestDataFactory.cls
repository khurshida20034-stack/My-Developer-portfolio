/**
 * Builds portfolio records for Apex tests.
 */
@IsTest
public class TestDataFactory {
    public static List<Portfolio_Project__c> createProjects(Integer count, Boolean published) {
        List<Portfolio_Project__c> records = new List<Portfolio_Project__c>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Portfolio_Project__c(Name = 'Project ' + i, Is_Published__c = published, Display_Order__c = i));
        }
        insert records;
        return records;
    }

    public static List<Portfolio_Skill__c> createSkills(Integer count, Boolean published) {
        List<Portfolio_Skill__c> records = new List<Portfolio_Skill__c>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Portfolio_Skill__c(Name = 'Skill ' + i, Category__c = 'Cat', Proficiency__c = 50, Is_Published__c = published));
        }
        insert records;
        return records;
    }

    public static List<Portfolio_Experience__c> createExperiences(Integer count, Boolean published) {
        List<Portfolio_Experience__c> records = new List<Portfolio_Experience__c>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Portfolio_Experience__c(Name = 'Role ' + i, Entry_Type__c = 'Work', Is_Published__c = published));
        }
        insert records;
        return records;
    }

    public static List<Portfolio_Certification__c> createCertifications(Integer count, Boolean published) {
        List<Portfolio_Certification__c> records = new List<Portfolio_Certification__c>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Portfolio_Certification__c(Name = 'Cert ' + i, Is_Published__c = published));
        }
        insert records;
        return records;
    }

    public static List<Portfolio_Blog_Post__c> createBlogPosts(Integer count, Boolean published) {
        List<Portfolio_Blog_Post__c> records = new List<Portfolio_Blog_Post__c>();
        for (Integer i = 0; i < count; i++) {
            records.add(new Portfolio_Blog_Post__c(Name = 'Post ' + i, Published_Date__c = Date.today(), Is_Published__c = published));
        }
        insert records;
        return records;
    }

    public static User createPortfolioUser() {
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String unique = 'pf' + String.valueOf(Crypto.getRandomInteger()).replace('-', 'n');
        User portfolioUser = new User(
            Alias = 'pfuser', Email = unique + '@example.com', EmailEncodingKey = 'UTF-8', LastName = 'PortfolioTester',
            LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_US', ProfileId = standardProfile.Id,
            TimeZoneSidKey = 'America/Los_Angeles', Username = unique + '@example.com.pftest'
        );
        insert portfolioUser;
        PermissionSet adminAccess = [SELECT Id FROM PermissionSet WHERE Name = 'Portfolio_Admin_Access' LIMIT 1];
        insert new PermissionSetAssignment(AssigneeId = portfolioUser.Id, PermissionSetId = adminAccess.Id);
        return portfolioUser;
    }
}
