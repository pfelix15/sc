@isTest
public class stagingContactTestFactory {
    public static List<staging_Contact__c> createSCs(Integer numScs, String function) {
        List<staging_contact__c> CreatedStaging = new List<staging_contact__c>();
        for (Integer i = 0; i < numScs; ++i) {
            staging_contact__c sc = new staging_contact__c(
            	Contact_Last_Name__c = 'testsub' + i,
                Contact_Email__c = i + 'nevermap@gmail.com.invalid',
                Function__c = function,
                Last_School_Attended__c  = '000023324-EI',
                Program_of_Interest__c = 'Bachelor of Science in Architecture: First-Year',
                Campaign__c = '701c0000000mw9YAAQ'
            );
            createdstaging.add(sc);
        }
        
        system.debug(createdStaging);
        return CreatedStaging;
    }
}