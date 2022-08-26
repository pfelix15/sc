@isTest
public class contactCheckCreateTest {
    @isTest static void testTriggerWithOneSC() {
        List<staging_contact__c> listofSC = stagingContactTestFactory.createSCs(8, 'Prospect');
        List<staging_contact__c> listofSC2 = stagingContactTestFactory.createSCs(8, 'UMID');
        List<staging_contact__c> listofSC3 = stagingContactTestFactory.createSCs(8, 'HOI');
        staging_contact__c sc = new staging_contact__c(UMID__c  = '12345645', 
                                                       	Contact_Last_Name__c = 'testsub',
                                                      	Contact_Email__c = 'nevermap@gmail.com.test',
                                                      	Function__c = 'Prospect');
        staging_contact__c sc1 = new staging_contact__c(UMID__c  = '12345678', 
                                                       	Contact_Last_Name__c = 'testsub',
                                                      	Contact_Email__c = 'nevermap@gmail.com.test',
                                                      	Function__c = 'Prospect');
        staging_contact__c sc2 = new staging_contact__c(UMID__c  = '12345678', 
                                                       	Contact_Last_Name__c = 'testsub',
                                                      	Contact_Email__c = 'nevermap@gmail.com.test',
                                                      	Function__c = 'Prospect');
        //List<sobject> accounts = Test.loadData(Account.sobjectType, 'testAccounts');
        //List<sobject> recruitmentIndex = Test.loadData(Recruitment_Academic_Index__c.sobjectType, 'testRecruitmentAcademicIndex');
        Test.startTest();
        insert listofSC;
        insert listofSC2;
        insert listofSC3;
        insert sc;
        insert sc1;
        insert sc2;
        Test.stopTest();
    }
}