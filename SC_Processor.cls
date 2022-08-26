/***************************
 * Name: SC_Processor
 * Created by Felix Partington and David Schmitke {DateCreated 06/01/2021} 
----------------------------------------------------------------------------------
 * Purpose: 
** Processes new Staging_Contact__c records by inserting/matching Contacts and creating associated child records
** Repurposed from Interactions-for-Student-Recruitment developed by SFDO
 * Methods: 
** SC_Processor() - constructor
** processRecruitment() - Main method for processing new Staging_Contact__c records for Recruitment purposes
----------------------------------------------------------------------------------
* History:
* VERSION       DEVELOPER NAME      DATE        DETAIL/FEATURES
* 1.0           Felix Partington   06/01/2020  Initial exploration of contact matching and triggering class
* 1.1           David Schmitke     06/16/2020  Combined initial dev work into single processor class
* 1.2           Felix Partington   06/22/2020   Finished mappings and logerrors
*/

public with sharing class SC_Processor {
    // set var 
    //Not in use currently
    private Map<Id, Staging_Contact__c> scMap = new Map<Id, Staging_Contact__c>();
    //Not used Ever
    private List<Staging_Contact__c> listSCtoUpdate = new List<Staging_Contact__c>();
    //List of contacts with a duplicate
    public List<Contact> MatchedContacts = new List<Contact>();
    //list of contacts that are created
    public List<Contact> CreatedContacts = new List<Contact>();
    //copy of Trigger.new staging contacts
    public List<Staging_Contact__c> stagingToProcess = new List<Staging_Contact__c>();
    //Keeps track of which staging contacts created contacts
    public List<Integer> ContactIndexesCreated = new List<Integer>();
    //Keeps track of which staging contacts created inquires
    public List<Integer> InquiryIndexesCreated = new List<Integer>();
    //Keeps track of which staging contacts created campaign Members 
    public List<Integer> CampaignMemberIndexesCreated = new List<Integer>();
    //List of Contacts that are attempting to be inserted
    public List<Contact> listConToInsert = new List<Contact>();
    //enum class to determine which type of 
    public enum typeOfUpload {PROSPECT, UMID, HOI}
    public typeOfUpload SCtype;
    public List<Boolean> shouldOperateOn = new List<Boolean>();
    //Object to hold results of class
    public Staging_Results__c resultsOfClass = new Staging_Results__c();
    


    //property that instantiates the contactMapping class
    private SC_MappingService scMappingService {
        get {
            if (scMappingService == null) {
                //Set type of mapping to prospect
            	if (SCtype == typeOfUpload.PROSPECT) {
                	scMappingService = new SC_MappingService(1);
            	}
           		 //set type of mapping to UMID
            	else if (SCtype == typeOfUpload.UMID) {
                	scMappingService = new SC_MappingService(2);
            	}
            	//set type of mapping to HOI
            	else if (SCtype == typeOfUpload.HOI) {
                	scMappingService = new SC_MappingService(3);
            	}
            }
			/* SET ONLY ONCE
            //Set type of mapping to prospect
            if (SCtype == typeOfUpload.PROSPECT) {
                scMappingService.setEnum(1);
            }
            //set type of mapping to UMID
            else if (SCtype == typeOfUpload.UMID) {
                scMappingService.setEnum(2);
            }
            //set type of mapping to HOI
            else if (SCtype == typeOfUpload.HOI) {
                scMappingService.setEnum(3);
            }*/
            return scMappingService;
        }

        set;
    }


    //constructor copies list of staging contacts into stagingToProcess
    public SC_Processor(List<Staging_Contact__c> insertedContacts, Integer type) {
        
        resultsOfClass = [SELECT Id FROM staging_results__c order by createdDate DESC LIMIT 1];
        stagingToProcess = insertedContacts;
        if (type == 1) {
            SCtype = typeOfUpload.PROSPECT;
        }
        else if (type == 2) {
            SCtype = typeOfUpload.UMID;
        }
        else if (type == 3) {
            SCtype = typeOfUpload.HOI;
        }
    }

    /**
     * @description preProcessing method for processing new Staging_Contact__c records for Recruitment purposes. 
     ** Processes new Staging_Contact__c records by updating/matching Contacts, 
     ** inserting Inquiry__c, and upserting CampaignMembers. 
     * 
     */
    
    public void preProcessRecruitmentWithUMID() {
        system.debug(' <> Begin preProcessRecruitmentWithUMID ');
        List<Contact> constructContacts = new List<Contact>();
         // Construct Con from new Staging records
         SC_MappingService mapping = new SC_MappingService(1);
         for (staging_contact__c s : stagingToProcess) {
            //create new contact and map fields
           Contact c = new Contact();
           mapping.applyDataToSObjectUpdate(s, c);
           c.EMPLID__c = s.UMID__c;

           system.debug('*** Constructing UMID Contact ' + c);
           //add to list to upsert
           constructContacts.add(c);
       } 
       Schema.SObjectField umField = Contact.EMPLID__c;
       Database.UpsertResult [] ur = Database.upsert(constructContacts, umField, false);
       Integer count = 0;
       for (Database.upsertResult result : ur) {
            if (result.isSuccess()) {
                
                stagingToProcess[count].Should_Operate_On__c = false;
                stagingToProcess[count].Contact_Status__c = 'Matched';
                 Contact c = new contact();
                 c.id = result.getId();
                 MatchedContacts.add(c);               
                 // Grab matched record to use instead of the new one, that didn't insert
                 stagingToProcess[count].Contact__c = c.id;
            }
            else {
                stagingToProcess[count].Should_Operate_On__c = true;
            }
            ++count;
       }
       
    }


    /**
     * @description Main method for processing new Staging_Contact__c records for Recruitment purposes. 
     ** Processes new Staging_Contact__c records by inserting/matching Contacts, 
     ** inserting Inquiry__c, and upserting CampaignMembers. 
     * 
     */
    
    public void processRecruitment() { 
        system.debug('LINE 148');
        system.debug('### FIRST ROW IS ' + stagingToProcess[0].UMID__c);
        //check if there can be a match by UMID
        if (stagingToProcess[0].UMID__c != null) {
            //if there is umids, only use the ones that fail a match
            system.debug('LINE 148x');
        system.debug('### FIRST ROW IS ' + stagingToProcess[0].UMID__c);
            preProcessRecruitmentWithUMID();
        } 

        system.debug('LINE 148xx');
        system.debug('### FIRST ROW IS ' + stagingToProcess[0].UMID__c);
        
        Integer contactCount = 0;
        
        // Construct Con from new Staging records
        for (staging_contact__c s : stagingToProcess) {
            if (s.Should_Operate_On__c == true) {
                
                //create new contact and map fields
                Contact c = new Contact ();
                scMappingService.applyDataToSObjectInsert(s, c);
                
                system.debug('*** Constructed Insert Contact ' + c);
                //add to list to insert
                listConToInsert.add(c);
                ContactIndexesCreated.add(contactCount);
            }
            ++contactCount;
        } 
        //system.assert(false);
        if (!listConToInsert.isEmpty()) {
            //Insert and call LogErrors
            Database.SaveResult[] srlist = Database.insert(listConToInsert, false); 
            system.debug('!!! Insert Contacts');
            LogSuccessError(srlist, 'Contact');
            system.debug('!!! Update Contacts ');
            update MatchedContacts;
        }
        
        //DELETE ONCE LOGPOSSIBLEERRORS is confirmed
        //insertContacts(listConToInsert); 
        
        //If Inquiry fields provided, construct and insert 
        //List of Inquires to insert
        List<Inquiry__c> listInqToInsert = new List<Inquiry__c>();
        Integer counter = 0;
        
        // Loop SC and construct inq 
        // in the future this will all occur in the mapping class 
        
        for (staging_contact__c s : stagingToProcess) {
            
            if (s.Program_of_Interest__c != null) {

                system.debug('Inquiry Should be made');
                //create inquiry and apply mappings
                Inquiry__c inq = new Inquiry__c();
                scMappingService.applyDataToSObjectInsert(s, inq);
               
                //populate staging contact lookup
                inq.Staging_Contact__c = s.id;
                system.debug('*** Constructed Inquiry__c ' + inq);
                //add to list to insert and the index at which an inquiry is created
                listInqToInsert.add(inq);
                InquiryIndexesCreated.add(counter);
            }
            
            ++counter;
        }
        
        //insert inquries and save the results
        if (listInqToInsert.size() > 0) {
            system.debug('!!! Insert Inquiries');
            Database.SaveResult[] inqlist = Database.insert(listInqToInsert, false); 
            LogSuccessError(inqlist, 'Inquiry__c');
        }
        // Insert Inquiry
        
        
        //If CampaignMember fields provided, construct and insert 
        List<campaignMember> listofConMemstoInsert = new List<CampaignMember>();
        Integer counter1 = 0;
        
        for (staging_contact__c sc: stagingToProcess) {
            if (sc.Campaign__c != null) {
                
                
                system.debug('CampMem Should be made');
                //create campaignMember and map the fields 
                CampaignMember campMem = new CampaignMember();
                scMappingService.applyDataToSObjectInsert(sc, campMem);
                //populate the staging contact lookup field 
                campMem.Staging_Contact__c = sc.id;
                //add to list to insert and the index at which an campaignMember is created
                listofConMemstoInsert.add(campMem);
                CampaignMemberIndexesCreated.add(counter1);
                
                
                
            }
            ++counter1;
        }
        
        //insert list of campaignMembers and connect 
        if (listofConMemstoInsert.size() > 0) {
            system.debug('!!! Insert CampaignMembers');
            Database.SaveResult[] camplist = Database.insert(listofConMemstoInsert, false); 
            LogSuccessError(camplist, 'CampaignMember');
        }
        
        for (staging_contact__c sc: stagingToProcess) {
            sc.Staging_Results__c = resultsOfClass.id;
        }
        resultsOfClass.Contacts_Matched__c = MatchedContacts.size();

        // Finally, associate update Staging_Contact__c records so user knows the outcome of each record
        Update resultsOfClass;
        Update stagingToProcess;
        system.debug('!!! Staging_Contact__c records updated');
        
        system.debug('!!! End SC_Processor.processRecruitment() ');
    }

    /* @description Debugs SaveResult errors if they happen. writes back to staging contact
     * @param srlist the Database.SaveResult List to check.
     */
    private void LogSuccessError(Database.SaveResult[] srlist, String objectType) {
		system.debug( ' <> Begin LogSuccessError ');
        system.debug( ' SR Size for ' + objectType + srlist.size());
        //grab name of object being inserted, CHECK whether it is API Name or Label
        String objectName = objectType;
        //counts how many contacts errored
        Integer errorContacts = 0;
        
        Integer createdContactsCount = 0;
        //Index of the staging object to write to 
        Integer Index = 0;
        Integer InquirySuccess = 0;
        Integer InquiryErrors = 0;
        Integer CampaignSuccess = 0;
        Integer CampaignErrors = 0;
        Integer CampaignMatching = 0;
        //Run through list of errors
        for (Database.SaveResult sr : srlist) {
            
            //Successfully inserted
            if (sr.isSuccess()) {
                if (objectName == 'Contact') {
                    //grab id of contact inserted
                    Id conId = sr.getId();
                    
                    //populate contact lookup field and status
                    stagingToProcess[ContactIndexesCreated[index]].Contact__c = conId; // Populate lookup on SC with new Con Id
                    stagingToProcess[ContactIndexesCreated[index]].Contact_Status__c = 'Created';
                    //List to keep track of created contacts
                    CreatedContacts.add(listConToInsert[index]);
                    ++createdContactsCount;
                }
                else if (objectName == 'Inquiry__c') {
                    //get lookup field from indexes that created the inquiry
                    stagingToProcess[InquiryIndexesCreated[index]].Inquiry__c = sr.getId();
                    stagingToProcess[InquiryIndexesCreated[index]].Inquiry_Status__c = 'Created';
                    ++InquirySuccess;
                }
                else if (objectName == 'CampaignMember') {
                    
                    //get lookup field from indexes that created the CampaignMember and populate fields
                    stagingToProcess[CampaignMemberIndexesCreated[index]].Campaign_Member_Id__c = (String)sr.getId();
                    stagingToProcess[CampaignMemberIndexesCreated[index]].Campaign_Member_Status__c = 'Created';
                    ++CampaignSuccess;
                }
                
            }
            else {
                //loop through errors on an insert
                for (Database.Error error : srlist[Index].getErrors()) {
                    //check if insert was an error because it was a duplicate
                    if (error.getStatusCode() == StatusCode.DUPLICATES_DETECTED) {
                        Database.DuplicateError dupErrorError = (Database.DuplicateError) error;
                        for (Datacloud.MatchResult matchResult : dupErrorError.getDuplicateResult().getMatchResults()) {
                            for (Datacloud.MatchRecord match : matchResult.getMatchRecords()) {
                                
                                //use lookup field to get staging contact
                                Contact c = (Contact)(scMappingService.applyDataToSObjectUpdate(stagingToProcess[ContactIndexesCreated[index]], match.getRecord()));
                                
                                // Grab matched record to use instead of the new one, that didn't insert
                                stagingToProcess[ContactIndexesCreated[index]].Contact__c = c.id;
                                stagingToProcess[ContactIndexesCreated[index]].Contact_Status__c = 'Matched';
 
                                
                                // Add existing Contact Ids to List so we know what Con were matched
                                MatchedContacts.add(c);
                                
                                
                                }
                            }
                        }
                    else { // Catch-all for all other errors
                        if (objectName == 'Contact') {
                            //set error message and contact status
                            stagingToProcess[ContactIndexesCreated[index]].Contact_Error_Message__c = 'Reason: Error during Contact insert - ' + error.getMessage() + '.';
                            stagingToProcess[ContactIndexesCreated[index]].Contact_Status__c = 'Error';
                            System.debug('Error during Contact insert - ' + error.getMessage() + '.');
                            ++errorContacts;
                        }
                        else if (objectName == 'Inquiry__c') {
                            //set error message and contact status
                            stagingToProcess[InquiryIndexesCreated[index]].Inquiry_Error_Message__c = 'Reason: Error during Inquiry insert - ' + error.getMessage() + '.';
                            stagingToProcess[InquiryIndexesCreated[index]].Inquiry_Status__c = 'Error';
                            System.debug('Error during Inquiry insert - ' + error.getMessage() + '.');
                            ++InquiryErrors;
                        }
                        else if (objectName == 'CampaignMember'){
                            //set error message and contact status
                            stagingToProcess[CampaignMemberIndexesCreated[index]].Campaign_Member_Error_Message__c	 = 'Reason: Error during Campaign Member insert - ' + error.getMessage() + '.';
                            
                            System.debug('Error during CampaignMember insert - ' + error.getMessage());
                            if (error.getMessage() == 'Already a campaign member.') {
                                stagingToProcess[CampaignMemberIndexesCreated[index]].Campaign_Member_Status__c = 'Pre-exisiting';
                                ++CampaignMatching;
                            }
                            else {
                                stagingToProcess[CampaignMemberIndexesCreated[index]].Campaign_Member_Status__c = 'Error';
                                ++CampaignErrors;
                            }
                        }
                    }
                }
            }
            //increment index
            ++Index;
            

        }
        //Set Variables 
        if (objectName == 'Contact') {
            resultsOfClass.Contacts_Created__c = createdContactsCount;
            
            resultsOfClass.Contact_Errors__c = errorContacts;
        }
        else if (objectName == 'Inquiry__c') {
            resultsOfClass.Inquiries_Created__c = InquirySuccess;
            resultsOfClass.Inquiry_Errors__c = InquiryErrors;
        }
        else if (objectName == 'CampaignMember') {
            resultsOfClass.Campaign_Members_Created__c = CampaignSuccess;
            resultsOfClass.Campaign_Members_Error__c = CampaignErrors;
            resultsOfClass.Campaign_Members_Pre__c = CampaignMatching;
        }


    }
}