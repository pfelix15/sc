trigger ContactCheckCreate on Staging_Contact__c (after insert) {
    /*Integer insertCounter = 0;
    Integer UpdateCounter = 0;
    Boolean isContact = false;
    List<Contact> inOrg = new List<Contact>();
    for (Staging_Contact__c sc: Trigger.new) {
        string Personemail = sc.Contact_Email__c;
        Contact c = new Contact(LastName = sc.Contact_Last_Name__c, Email = sc.Contact_Email__c);
        inOrg.add(c);
        Datacloud.FindDuplicatesResult[] results = Datacloud.FindDuplicates.findDuplicates(inOrg);

        system.debug('First Object' + results.size());
        system.debug(Datacloud.FindDuplicates.findDuplicates(inOrg).size());
        for (Datacloud.FindDuplicatesResult findDupeResult : results) {
            system.debug('1');
            for (Datacloud.DuplicateResult dupeResult : findDupeResult.getDuplicateResults()) {
                system.debug('2');
                for (Datacloud.MatchResult matchResult : dupeResult.getMatchResults()) {
                    system.debug('3');
                    for (Datacloud.MatchRecord matchRecord : matchResult.getMatchRecords()) {
                        System.debug('Duplicate Record: ' + matchRecord.getRecord());
                        isContact = true;
                        sc.Contact__c = matchRecord.getRecord().id;
                    }
                }
            }
        }
        if (isContact == false) {
            insert c;
            sc.Contact__c = c.id;
            ++insertCounter;
        }
        inOrg.clear();
    }*/
    List<Staging_Contact__c> stagingToProcess = new List<Staging_Contact__c>();
   
    //Clone so we can use the id
    for (staging_Contact__c sc : Trigger.new) {
        Staging_Contact__c clonedStaging = sc.clone(true, false, true, true); // Clone because After Trigger context, we need the Id for processing.
        stagingToProcess.add(clonedStaging);
        
    }
    system.debug('StagingToProcess   ' + stagingToProcess);
    system.debug('Trigger.New  ' + Trigger.new);
    system.debug('Trigger.new[0].id  ' + Trigger.new[0].id);
    system.debug('stagingToProcess[0].id  ' + stagingToProcess[0].id);
    
    if (trigger.new[0].function__c == 'Prospect') {
    	SC_Processor tester = new SC_Processor(stagingToProcess,1);
        tester.ProcessRecruitment();
    }
    else if (trigger.new[0].function__c == 'UMID') {
    	SC_Processor tester = new SC_Processor(stagingToProcess,2);
        tester.ProcessRecruitment();
    }
    else if (trigger.new[0].function__c == 'HOI') {
    	SC_Processor tester = new SC_Processor(stagingToProcess,3);
        tester.ProcessRecruitment();
    }
    
    
}