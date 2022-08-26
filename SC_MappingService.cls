/***************************
 * Name: ContactMapping
 * Created by Felix Partington and David Schmitke {DateCreated 06/22/2021} 
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
* 1.0           Felix Partington   06/22/2020  Initial exploration of contact, Inquiry, and Campaign Member Mappings 
* 
*/
public with sharing class SC_MappingService {

    
    //Stores CampaignMember, Contact, and Inquiry
    private Set<String> objectNames = new Set<String>();
    //Holds custom metadata for insert mappings
    public Map<String, List<SC_Mapping_Prospect__mdt>> intMappingMapInsert = new Map<String, List<SC_Mapping_Prospect__mdt>>();
    //Holds custom metadata for update mappings
    public Map<String, List<SC_Mapping_Prospect__mdt>> intMappingMapUpdate = new Map<String, List<SC_Mapping_Prospect__mdt>>();
    //Holds all recuritment Acadmic indexes
    private Map<String, List<Recruitment_Academic_Index__c>> recruitingDictionary = new Map<String, List<Recruitment_Academic_Index__c>>();
    public enum typeOfUpload { PROSPECT, UMID, HOI }
    public typeOfUpload mappingType;
    //NEW TODO
    public Map<String, List<UMID__MDT>> UMIDMappingMapInsert = new Map<String, List<UMID__MDT>>();
    //Holds custom metadata for update mappings TODO
    public Map<String, List<UMID__MDT>> UMIDMappingMapUpdate = new Map<String, List<UMID__MDT>>();
    //NEW TODO
    public Map<String, List<HOI__MDT>> HOIMappingMapInsert = new Map<String, List<HOI__MDT>>();
    //Holds custom metadata for update mappings
    public Map<String, List<HOI__MDT>> HOIMappingMapUpdate = new Map<String, List<HOI__MDT>>();
    //Object to hold results of class
    public Staging_Results__c resultsOfClass = new Staging_Results__c();



    public void setEnum(Integer input) {
        if (input == 1) {
            mappingType = typeOfUpload.PROSPECT;
        }
        else if (input == 2) {
            mappingType = typeOfUpload.UMID;
        }
        else if (input == 3) {
            mappingType = typeOfUpload.HOI;
        }
    }
    
    /**
     * @description Constructor method for filling in the metadata maps and map of  
     ** recruitment Index
     ** 
     **
     */
    public SC_MappingService(Integer type) {
        setEnum(type);
        
        //Select all SC mappings, What is it stored as?
        if (mappingType == typeOfUpload.PROSPECT) {
            for (SC_Mapping_Prospect__mdt sm : [
                SELECT Target_Field__r.QualifiedAPIName, Target_Object__r.QualifiedAPIName,Insert__c, Update__c, 
                Source_Object__c, Source_Field__r.QualifiedAPIName
                FROM SC_Mapping_Prospect__mdt WHERE Insert__c = true
            
            ] ) {
                //Add Objects to set, Should eventually be of size three: contact,Inquiry, and Campaign
                objectNames.add(sm.Target_Object__r.QualifiedAPIName);


                //if there is not already the mapping for the object add new list of qualified API Names
                if (!intMappingMapInsert.containsKey(sm.Target_Object__r.QualifiedAPIName)) {
                 intMappingMapInsert.put(sm.Target_Object__r.QualifiedAPIName, new List<SC_Mapping_Prospect__mdt>{sm});
                } else {
                    intMappingMapInsert.get(sm.Target_Object__r.QualifiedAPIName).add(sm);
                }

            
            }
            //Same as above but for update mappings
            for (SC_Mapping_Prospect__mdt sm : [
                SELECT Target_Field__r.QualifiedAPIName, Target_Object__r.QualifiedAPIName,Insert__c, Update__c, 
                Source_Object__c, Source_Field__r.QualifiedAPIName
                FROM SC_Mapping_Prospect__mdt WHERE Update__c = true
            
            ]) {
                //Add Objects to set, Should eventually be of size three: contact,Inquiry, and Campaign
                objectNames.add(sm.Target_Object__r.QualifiedAPIName);


                //if there is not already the mapping for the object add new list of qualified API Names
                if (!intMappingMapUpdate.containsKey(sm.Target_Object__r.QualifiedAPIName)) {
                    intMappingMapUpdate.put(sm.Target_Object__r.QualifiedAPIName, new List<SC_Mapping_Prospect__mdt>{sm});
                }   else {
                    intMappingMapUpdate.get(sm.Target_Object__r.QualifiedAPIName).add(sm);
             }

            
            }

            //select recruitment academic indexes to transfer to inquiries
            for (Recruitment_Academic_Index__c s: [SELECT Name, Level__c, Academic_Program__c, 
                Program_Plan__c, Program_Plan_Code__c, Plan_Requirement__c, 
                Plan_Requirement_Code__c, Anticipated_Start_Term__c, Admit_Type__c  FROM Recruitment_Academic_Index__c ]) {
                    //If it contains the name already add the index
                    if (!recruitingDictionary.containsKey(s.Name)) {
                    
                        recruitingDictionary.put(s.Name, new List<Recruitment_Academic_Index__c>{s});
                    }
                    else {
                        recruitingDictionary.get(s.Name).add(s);
                    }
                }
        }
        else if (mappingType  == typeOfUpload.UMID) {
            for (UMID__MDT sm : [
                SELECT Target_Field__r.QualifiedAPIName, Target_Object__r.QualifiedAPIName,Insert__c, Update__c, 
                Source_Object__c, Source_Field__r.QualifiedAPIName
                FROM UMID__MDT WHERE Insert__c = true
            
            ] ) {
                //Add Objects to set, Should eventually be of size three: contact,Inquiry, and Campaign
                /*objectNames.add(sm.Target_Object__r.QualifiedAPIName);


                //if there is not already the mapping for the object add new list of qualified API Names
                if (!UMIDMappingMapInsert.containsKey(sm.Target_Object__r.QualifiedAPIName)) {
                    UMIDMappingMapInsert.put(sm.Target_Object__r.QualifiedAPIName, new List<UMID__MDT>{sm});
                } else {
                    UMIDMappingMapInsert.get(sm.Target_Object__r.QualifiedAPIName).add(sm);
                }*/

            
            }
            //Same as above but for update mappings
            for (UMID__MDT sm : [
                SELECT Target_Field__r.QualifiedAPIName, Target_Object__r.QualifiedAPIName,Insert__c, Update__c, 
                Source_Object__c, Source_Field__r.QualifiedAPIName
                FROM UMID__MDT WHERE Update__c = true
            
            ]) {
                //Add Objects to set, Should eventually be of size three: contact,Inquiry, and Campaign
                /*objectNames.add(sm.Target_Object__r.QualifiedAPIName);


                //if there is not already the mapping for the object add new list of qualified API Names
                if (!UMIDMappingMapUpdate.containsKey(sm.Target_Object__r.QualifiedAPIName)) {
                    UMIDMappingMapUpdate.put(sm.Target_Object__r.QualifiedAPIName, new List<UMID__MDT>{sm});
                }   else {
                    UMIDMappingMapUpdate.get(sm.Target_Object__r.QualifiedAPIName).add(sm);
             }*/

            
            }

            //select recruitment academic indexes to transfer to inquiries
            /*for (Recruitment_Academic_Index__c s: [SELECT Name, Level__c, Academic_Program__c, 
                Program_Plan__c, Program_Plan_Code__c, Plan_Requirement__c, 
                Plan_Requirement_Code__c, Anticipated_Start_Term__c, Admit_Type__c  FROM Recruitment_Academic_Index__c ]) {
                    //If it contains the name already add the index
                    if (!recruitingDictionary.containsKey(s.Name)) {
                    
                        recruitingDictionary.put(s.Name, new List<Recruitment_Academic_Index__c>{s});
                    }
                    else {
                        recruitingDictionary.get(s.Name).add(s);
                    }
                }*/
        }
        else if (mappingType  == typeOfUpload.HOI) {
            for (HOI__MDT sm : [
                SELECT Target_Field__r.QualifiedAPIName, Target_Object__r.QualifiedAPIName,Insert__c, Update__c, 
                Source_Object__c, Source_Field__r.QualifiedAPIName
                FROM HOI__MDT WHERE Insert__c = true
            
            ] ) {
                //Add Objects to set, Should eventually be of size three: contact,Inquiry, and Campaign
               /* objectNames.add(sm.Target_Object__r.QualifiedAPIName);


                //if there is not already the mapping for the object add new list of qualified API Names
                if (!HOIMappingMapInsert.containsKey(sm.Target_Object__r.QualifiedAPIName)) {
                    HOIMappingMapInsert.put(sm.Target_Object__r.QualifiedAPIName, new List<HOI__MDT>{sm});
                } else {
                    HOIMappingMapInsert.get(sm.Target_Object__r.QualifiedAPIName).add(sm);
                }*/

            
            }
            //Same as above but for update mappings
            for (HOI__MDT sm : [
                SELECT Target_Field__r.QualifiedAPIName, Target_Object__r.QualifiedAPIName,Insert__c, Update__c, 
                Source_Object__c, Source_Field__r.QualifiedAPIName
                FROM HOI__MDT WHERE Update__c = true
            
            ]) {
                //Add Objects to set, Should eventually be of size three: contact,Inquiry, and Campaign
                /*objectNames.add(sm.Target_Object__r.QualifiedAPIName);


                //if there is not already the mapping for the object add new list of qualified API Names
                if (!HOIMappingMapUpdate.containsKey(sm.Target_Object__r.QualifiedAPIName)) {
                    HOIMappingMapUpdate.put(sm.Target_Object__r.QualifiedAPIName, new List<HOI__MDT>{sm});
                }   else {
                    HOIMappingMapUpdate.get(sm.Target_Object__r.QualifiedAPIName).add(sm);
             }*/

            
            }
        }
    }



    /**
     * @description takes in a staging object and an sObject. Takes information 
     * from custom metadata to map the fields for objects that are inserted
     */
    public SObject applyDataToSObjectInsert(Staging_Contact__c stagingCon, SObject theObject) {
        String objectName = theObject.getSObjectType().getDescribe().getName();
		system.debug('<> Begin applyDataToSObjectInsert ');
        if (mappingType == typeOfUpload.PROSPECT) {
            //Prevents Mapping from metaData paths not yet created
            if (intMappingMapInsert.containsKey(objectName)) {
                for (SC_Mapping_Prospect__mdt mapping : intMappingMapInsert.get(objectName)) {
                        //How to make sure this is only of the specified sObject type
                        theObject.put(mapping.Target_Field__r.QualifiedAPIName, stagingCon.get(mapping.Source_Field__r.QualifiedAPIName));
                        
                        

                }
                theObject.put('Last_Data_Input_source__c', 'STG - ' + stagingCon.Owner.username + ' - ' + System.Today().format());
                if (objectName == 'Inquiry__c') {
                      system.debug('<> Begin inquiryMappingHelper ');
                      //if the staging contact has a last school attended value 
                      inquiryMappingHelper((Inquiry__c)theObject, stagingCon);
                     
                }
            }
        }
        else if (mappingType == typeOfUpload.UMID) {
            if (UMIDMappingMapInsert.containsKey(objectName)) {
                /*for (UMID__mdt mapping : UMIDMappingMapInsert.get(objectName)) {
                        //How to make sure this is only of the specified sObject type
                        system.debug(mapping);
                    
                        theObject.put(mapping.Target_Field__r.QualifiedAPIName, stagingCon.get(mapping.Source_Field__r.QualifiedAPIName));
                        theObject.put('Last_Data_Input_source__c', 'STG - Insert ' + stagingCon.Id + ' - ' + System.Today());*/
                        //if the object is inquiry, map extra fields by calling the inquiry helper
                        /*if (objectName == 'Inquiry__c') {
                            system.debug('RUN INQUIRY');
                            inquiryMappingHelper((Inquiry__c)theObject, stagingCon);
                        }*/

                //}
            }
        }
        else if (mappingType == typeOfUpload.HOI) {
            if (HOIMappingMapInsert.containsKey(objectName)) {
               /* for (HOI__mdt mapping : HOIMappingMapInsert.get(objectName)) {
                        //How to make sure this is only of the specified sObject type
                        system.debug(mapping);
                    
                        theObject.put(mapping.Target_Field__r.QualifiedAPIName, stagingCon.get(mapping.Source_Field__r.QualifiedAPIName));
                        theObject.put('Last_Data_Input_source__c', 'STG - Insert ' + stagingCon.Id + ' - ' + System.Today());*/
                        //if the object is inquiry, map extra fields by calling the inquiry helper
                        /*if (objectName == 'Inquiry__c') {
                            system.debug('RUN INQUIRY');
                            inquiryMappingHelper((Inquiry__c)theObject, stagingCon);
                        }*/
				
                //}
            }
        }

        return theObject;
    }

    /**
     * @description takes in a staging object and an sObject. Takes information 
     * from the map about recruitment index to assign more fields to the inquiry object
     */
 
    
     public void inquiryMappingHelper(Inquiry__c theObject, Staging_Contact__c stagingCon ) {

            if (stagingCon.Last_School_Attended__c != null) {
                system.debug(' <> Has Last School Attended');
                // Create shell acct to hold reference
                Account acctSchool = new Account(); 
                system.debug('Last School Attended Ext ID ' + stagingCon.Last_School_Attended__c);
                String extid = stagingCon.Last_School_Attended__c;
                system.debug('### Variable Check - extid = ' + extid);
                acctSchool.External_ID__c = extid;
                theObject.Last_School_Attended__r = acctSchool;
            } 
            /* 

            //Create list for fake insert
            List<Account> selectOneAccount = new List<Account>();
            selectOneAccount.add(acctSchool);
            //grab field to match on
            Schema.SObjectField umField = Account.External_ID__c;
            //can never insert without name, if it can find External ID
            //it will be a success 
            Database.UpsertResult [] ur = Database.upsert(selectOneAccount, umField, false);
            // Add the acct to the Inquiry lookup field
            
            Id insertedAccount = acctSchool.id;
            
            //if it is a success map field 
            if (ur[0].isSuccess()) {
            	theObject.Last_School_Attended__c = ur[0].getId();
        	}  */

        //if the name passed into the stagin object is an index
        if (recruitingDictionary.containsKey(stagingCon.Program_of_Interest__c)) {
            //only one Recruitment_Academic_Index__c per name, loop should run once
            for (Recruitment_Academic_Index__c rai: recruitingDictionary.get(stagingCon.Program_of_Interest__c)) {
                //put data from Recruitment_Academic_Index__c into the inquiry
                theObject.put('Level__c', rai.Level__c);
                theObject.put('Academic_Program__c', rai.Academic_Program__c);
                theObject.put('Program_Plan__c', rai.Program_Plan__c);
                theObject.put('Program_Plan_Code__c', rai.Program_Plan_Code__c);
                theObject.put('Plan_Requirement__c', rai.Plan_Requirement__c);
                theObject.put('Plan_Requirement_Code__c', rai.Plan_Requirement_Code__c);
                theObject.put('Anticipated_Start_Term__c', rai.Anticipated_Start_Term__c);
                theObject.put('Admit_Type__c', rai.Admit_Type__c);
                
            }

            //make sure that the start year is not null
            if (stagingCon.Start_Year__c == null) {
                DateTime currentDate = System.Today();
                //if the current month is August or before set date to current year
                if (currentDate.Month() <= 8 ) {
                    theObject.Anticipated_Start_Year__c = String.valueof(currentDate.Year());
                } 
                //else, set year to the next year
                else {
                    theObject.Anticipated_Start_Year__c = String.valueof(currentDate.Year() + 1);

                }
            }
            //if there is a start year, map it to the object
            else {
                theObject.Anticipated_Start_Year__c = stagingCon.Start_Year__c;
            }
            //make sure that the start term is not null
            if (stagingCon.Start_Term__c == null) {
                theObject.Anticipated_Start_Term__c = 'Fall';
            }
            else {
                theObject.Anticipated_Start_Term__c = stagingCon.Start_Term__c;
            }
        }
        else {
            stagingCon.Inquiry_Error_Message__c = 'PROGRAM OF INTEREST NOT FOUND';
            stagingCon.Inquiry_Status__c = 'Error';
        }
        //THROW ERROR TO STAGING CONTACT IF THE PROGRAM IS NOT FOUND
        //ERROR MESSAGE: PROGRAM OF INTEREST NOT FOUND
        //CHANGE STATUS
    }

    /**
     * @description takes in a staging object and an sObject. Takes information 
     * from custom metadata to map the fields for objects that are needed to be updated
     */
    public SObject applyDataToSObjectUpdate(Staging_Contact__c stagingCon, SObject theObject) {
        String objectName = theObject.getSObjectType().getDescribe().getName();

        if (mappingType == typeOfUpload.PROSPECT) {
            //Prevents Mapping from metaData paths not yPet created
            if (intMappingMapUpdate.containsKey(objectName)) {
                for (SC_Mapping_Prospect__mdt mapping : intMappingMapUpdate.get(objectName)) {
                        //How to make sure this is only of the specified sObject type
                     if (String.valueof(stagingCon.get(mapping.Source_Field__r.QualifiedAPIName)) != 'false' 
                     && stagingCon.get(mapping.Source_Field__r.QualifiedAPIName) != null) {
                        theObject.put(mapping.Target_Field__r.QualifiedAPIName, stagingCon.get(mapping.Source_Field__r.QualifiedAPIName));
					}
                }
                theObject.put('Last_Data_Input_source__c', 'STG - ' + stagingCon.Owner.username + ' - ' + System.Today().format());
            }
        }
        /*else if (mappingType == typeOfUpload.UMID) {
            //Prevents Mapping from metaData paths not yPet created
            if (UMIDMappingMapUpdate.containsKey(objectName)) {
                for (UMID__mdt mapping : UMIDMappingMapUpdate.get(objectName)) {
                        //How to make sure this is only of the specified sObject type
                        if (String.valueof(stagingCon.get(mapping.Source_Field__r.QualifiedAPIName)) != 'false' 
                            && stagingCon.get(mapping.Source_Field__r.QualifiedAPIName) != null) {
                            theObject.put(mapping.Target_Field__r.QualifiedAPIName, stagingCon.get(mapping.Source_Field__r.QualifiedAPIName));
                            theObject.put('Last_Data_Input_source__c', 'STG - Update ' + stagingCon.Id + ' - ' + System.Today());
                     }
                }
            }
        }
        else if (mappingType == typeOfUpload.HOI){
            //Prevents Mapping from metaData paths not yPet created
            if (HOIMappingMapUpdate.containsKey(objectName)) {
                for (HOI__MDT mapping : HOIMappingMapUpdate.get(objectName)) {
                        //How to make sure this is only of the specified sObject type
                        if (String.valueof(stagingCon.get(mapping.Source_Field__r.QualifiedAPIName)) != 'false' 
                            && stagingCon.get(mapping.Source_Field__r.QualifiedAPIName) != null) {
                            theObject.put(mapping.Target_Field__r.QualifiedAPIName, stagingCon.get(mapping.Source_Field__r.QualifiedAPIName));
                            theObject.put('Last_Data_Input_source__c', 'STG - Update ' + stagingCon.Id + ' - ' + System.Today());
                        }
                }
            }
        }*/

        return theObject;
    }


    
}