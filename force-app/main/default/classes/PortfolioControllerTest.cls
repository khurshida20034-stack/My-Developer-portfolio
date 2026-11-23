@IsTest
private class PortfolioControllerTest {
    private static final Integer BULK_COUNT = 251;

    @TestSetup
    static void setupUser() {
        TestDataFactory.createPortfolioUser();
    }

    private static User portfolioUser() {
        return [SELECT Id FROM User WHERE LastName = 'PortfolioTester' LIMIT 1];
    }

    @IsTest
    static void shouldReturnOnlyPublishedRecords_WhenDataExists() {
        System.runAs(portfolioUser()) {
            TestDataFactory.createProjects(3, true);
            TestDataFactory.createProjects(2, false);
            TestDataFactory.createSkills(4, true);
            TestDataFactory.createExperiences(2, true);
            TestDataFactory.createCertifications(1, true);
            TestDataFactory.createBlogPosts(5, true);
            TestDataFactory.createBlogPosts(1, false);

            Test.startTest();
            PortfolioController.PortfolioData data = PortfolioController.getPortfolioData();
            Test.stopTest();

            Assert.areEqual(3, data.projects.size(), 'Only published projects should be returned');
            Assert.areEqual(4, data.skills.size(), 'Published skills should be returned');
            Assert.areEqual(2, data.experiences.size(), 'Published experiences should be returned');
            Assert.areEqual(1, data.certifications.size(), 'Published certifications should be returned');
            Assert.areEqual(5, data.blogPosts.size(), 'Only published blog posts should be returned');
        }
    }

    @IsTest
    static void shouldReturnEmptyLists_WhenNoData() {
        System.runAs(portfolioUser()) {
            Test.startTest();
            PortfolioController.PortfolioData data = PortfolioController.getPortfolioData();
            Test.stopTest();

            Assert.isTrue(data.projects.isEmpty(), 'Projects should be empty');
            Assert.isTrue(data.blogPosts.isEmpty(), 'Blog posts should be empty');
        }
    }

    @IsTest
    static void shouldCapResults_WhenMoreThanMaxRows() {
        System.runAs(portfolioUser()) {
            TestDataFactory.createSkills(BULK_COUNT, true);

            Test.startTest();
            PortfolioController.PortfolioData data = PortfolioController.getPortfolioData();
            Test.stopTest();

            Assert.areEqual(200, data.skills.size(), 'Results should be capped at 200 rows');
        }
    }

    @IsTest
    static void shouldSaveMessage_WhenInputValid() {
        System.runAs(portfolioUser()) {
            Test.startTest();
            Id savedId = PortfolioController.submitMessage('Asha', 'asha@example.com', '+911234567890', 'Hello', 'Nice portfolio');
            Test.stopTest();

            Portfolio_Contact_Message__c saved = [SELECT Sender_Name__c, Sender_Email__c, Subject__c, Message__c FROM Portfolio_Contact_Message__c WHERE Id = :savedId];
            Assert.areEqual('Asha', saved.Sender_Name__c, 'Name should be saved');
            Assert.areEqual('asha@example.com', saved.Sender_Email__c, 'Email should be saved');
            Assert.areEqual('Nice portfolio', saved.Message__c, 'Message should be saved');
        }
    }

    @IsTest
    static void shouldSendNotificationEmail_WhenMessageSaved() {
        System.runAs(portfolioUser()) {
            Test.startTest();
            PortfolioController.submitMessage('Asha', 'asha@example.com', null, 'Hello', 'Nice portfolio');
            Integer emailsSent = Limits.getEmailInvocations();
            Test.stopTest();

            Assert.areEqual(1, emailsSent, 'One notification email should be sent');
        }
    }

    @IsTest
    static void shouldBuildNotification_WithReplyToAndPlainBody() {
        Portfolio_Contact_Message__c record = new Portfolio_Contact_Message__c(
            Sender_Name__c = 'Asha',
            Sender_Email__c = 'asha@example.com',
            Subject__c = 'Hi\r\nBcc: attacker@example.com',
            Message__c = 'Nice portfolio'
        );

        Messaging.SingleEmailMessage mail = PortfolioController.buildNotification(record);

        Assert.areEqual('khurshida20034@gmail.com', mail.getToAddresses()[0], 'Notification should go to the owner');
        Assert.areEqual('asha@example.com', mail.getReplyTo(), 'Reply-to should be the visitor');
        Assert.isFalse(mail.getSubject().contains('\n'), 'Subject must not contain line breaks');
        Assert.isTrue(mail.getPlainTextBody().contains('Phone: Not provided'), 'Missing phone should be labelled');
        Assert.isTrue(mail.getPlainTextBody().contains('Nice portfolio'), 'Body should include the message');
    }

    @IsTest
    static void shouldNotSendEmail_WhenValidationFails() {
        System.runAs(portfolioUser()) {
            Test.startTest();
            try {
                PortfolioController.submitMessage('', 'a@example.com', null, null, 'Hi');
            } catch (AuraHandledException e) {
                Assert.isNotNull(e.getMessage(), 'Validation error expected');
            }
            Integer emailsSent = Limits.getEmailInvocations();
            Test.stopTest();

            Assert.areEqual(0, emailsSent, 'No email should be sent for invalid input');
        }
    }

    @IsTest
    static void shouldThrow_WhenNameBlank() {
        System.runAs(portfolioUser()) {
            Test.startTest();
            try {
                PortfolioController.submitMessage('', 'a@example.com', null, null, 'Hi');
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('name'), 'Message should mention the name');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrow_WhenMessageBlank() {
        System.runAs(portfolioUser()) {
            Test.startTest();
            try {
                PortfolioController.submitMessage('Asha', 'a@example.com', null, null, ' ');
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('message'), 'Message should mention the message');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void shouldThrow_WhenEmailInvalid() {
        System.runAs(portfolioUser()) {
            Test.startTest();
            try {
                PortfolioController.submitMessage('Asha', 'not-an-email', null, null, 'Hi');
                Assert.fail('Expected AuraHandledException');
            } catch (AuraHandledException e) {
                Assert.isTrue(e.getMessage().contains('email'), 'Message should mention the email');
            }
            Test.stopTest();
        }
    }
}
