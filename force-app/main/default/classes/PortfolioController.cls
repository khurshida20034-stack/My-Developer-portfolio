/**
 * Serves published portfolio content to the portfolio LWCs and saves contact form submissions.
 */
public with sharing class PortfolioController {
    private static final Integer MAX_ROWS = 200;
    private static final String NOTIFICATION_ADDRESS = 'khurshida20034@gmail.com';
    private static final Pattern EMAIL_PATTERN = Pattern.compile('^[a-zA-Z0-9._%+\\-]+@[a-zA-Z0-9.\\-]+\\.[a-zA-Z]{2,}$');

    /**
     * Wrapper holding every published section of the portfolio.
     */
    public class PortfolioData {
        @AuraEnabled public List<Portfolio_Project__c> projects;
        @AuraEnabled public List<Portfolio_Skill__c> skills;
        @AuraEnabled public List<Portfolio_Experience__c> experiences;
        @AuraEnabled public List<Portfolio_Certification__c> certifications;
        @AuraEnabled public List<Portfolio_Blog_Post__c> blogPosts;
    }

    /**
     * @return all published portfolio records, sorted for display
     */
    @AuraEnabled(cacheable=true)
    public static PortfolioData getPortfolioData() {
        try {
            PortfolioData data = new PortfolioData();
            data.projects = [
                SELECT Id, Name, Description__c, Tech_Stack__c, GitHub_URL__c, Demo_URL__c, Is_Featured__c, Display_Order__c
                FROM Portfolio_Project__c
                WHERE Is_Published__c = true
                WITH USER_MODE
                ORDER BY Is_Featured__c DESC, Display_Order__c ASC NULLS LAST, Name ASC
                LIMIT :MAX_ROWS
            ];
            data.skills = [
                SELECT Id, Name, Category__c, Proficiency__c, Display_Order__c
                FROM Portfolio_Skill__c
                WHERE Is_Published__c = true
                WITH USER_MODE
                ORDER BY Category__c ASC, Display_Order__c ASC NULLS LAST, Name ASC
                LIMIT :MAX_ROWS
            ];
            data.experiences = [
                SELECT Id, Name, Entry_Type__c, Organization__c, Location__c, Start_Date__c, End_Date__c, Is_Current__c, Description__c, Display_Order__c
                FROM Portfolio_Experience__c
                WHERE Is_Published__c = true
                WITH USER_MODE
                ORDER BY Display_Order__c ASC NULLS LAST, Start_Date__c DESC NULLS LAST
                LIMIT :MAX_ROWS
            ];
            data.certifications = [
                SELECT Id, Name, Issuer__c, Issue_Date__c, Credential_ID__c, Credential_URL__c, Display_Order__c
                FROM Portfolio_Certification__c
                WHERE Is_Published__c = true
                WITH USER_MODE
                ORDER BY Display_Order__c ASC NULLS LAST, Issue_Date__c DESC NULLS LAST
                LIMIT :MAX_ROWS
            ];
            data.blogPosts = [
                SELECT Id, Name, Summary__c, Body__c, External_URL__c, Published_Date__c
                FROM Portfolio_Blog_Post__c
                WHERE Is_Published__c = true
                WITH USER_MODE
                ORDER BY Published_Date__c DESC NULLS LAST
                LIMIT :MAX_ROWS
            ];
            return data;
        } catch (Exception e) {
            throw buildError('Unable to load portfolio content right now.');
        }
    }

    /**
     * Saves a visitor message from the contact form.
     * @param senderName visitor name
     * @param senderEmail visitor email
     * @param senderPhone optional visitor phone
     * @param subject optional subject
     * @param message message body
     * @return Id of the saved Portfolio_Contact_Message__c
     * @throws AuraHandledException when validation fails or the save fails
     */
    @AuraEnabled
    public static Id submitMessage(String senderName, String senderEmail, String senderPhone, String subject, String message) {
        if (String.isBlank(senderName) || String.isBlank(message)) {
            throw buildError('Please enter your name and a message.');
        }
        if (String.isBlank(senderEmail) || !EMAIL_PATTERN.matcher(senderEmail.trim()).matches()) {
            throw buildError('Please enter a valid email address.');
        }
        Portfolio_Contact_Message__c record = new Portfolio_Contact_Message__c(
            Sender_Name__c = senderName.trim().left(120),
            Sender_Email__c = senderEmail.trim(),
            Sender_Phone__c = String.isBlank(senderPhone) ? null : senderPhone.trim().left(40),
            Subject__c = String.isBlank(subject) ? null : subject.trim().left(255),
            Message__c = message.trim().left(5000)
        );
        Id savedId;
        try {
            Database.SaveResult result = Database.insert(record, AccessLevel.USER_MODE);
            savedId = result.getId();
        } catch (DmlException e) {
            throw buildError('Your message could not be sent. Please try again.');
        }
        sendNotification(record);
        return savedId;
    }

    @TestVisible
    private static Messaging.SingleEmailMessage buildNotification(Portfolio_Contact_Message__c record) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ NOTIFICATION_ADDRESS });
        mail.setReplyTo(record.Sender_Email__c);
        Id orgWideId = findOrgWideAddressId();
        if (orgWideId != null) {
            mail.setOrgWideEmailAddressId(orgWideId);
        } else {
            mail.setSenderDisplayName('Portfolio Contact Form');
        }
        mail.setSaveAsActivity(false);
        String subjectLine = String.isBlank(record.Subject__c) ? 'New message' : record.Subject__c.replaceAll('[\\r\\n]+', ' ');
        mail.setSubject('Portfolio: ' + subjectLine);
        mail.setPlainTextBody(
            'You have a new message from your portfolio website.\n\n' +
            'Name: ' + record.Sender_Name__c + '\n' +
            'Email: ' + record.Sender_Email__c + '\n' +
            'Phone: ' + (String.isBlank(record.Sender_Phone__c) ? 'Not provided' : record.Sender_Phone__c) + '\n\n' +
            'Message:\n' + record.Message__c
        );
        return mail;
    }

    // Guest users cannot query OrgWideEmailAddress, so its Id is kept in a custom label.
    private static Id findOrgWideAddressId() {
        String rawId = Label.Portfolio_Notification_Sender_Id;
        return String.isBlank(rawId) || !Pattern.matches('0D2[a-zA-Z0-9]{12}([a-zA-Z0-9]{3})?', rawId) ? null : (Id) rawId;
    }

    // The message is already saved, so an email failure must not surface as a form error.
    private static void sendNotification(Portfolio_Contact_Message__c record) {
        try {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ buildNotification(record) }, false);
            for (Messaging.SendEmailResult result : results) {
                if (result.isSuccess()) {
                    System.debug(LoggingLevel.INFO, 'Portfolio notification email accepted for delivery');
                    continue;
                }
                for (Messaging.SendEmailError err : result.getErrors()) {
                    System.debug(LoggingLevel.ERROR, 'Portfolio notification email failed: ' + err.getStatusCode() + ' - ' + err.getMessage());
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Portfolio notification email failed: ' + e.getMessage());
        }
    }

    private static AuraHandledException buildError(String message) {
        AuraHandledException ex = new AuraHandledException(message);
        ex.setMessage(message);
        return ex;
    }
}
