@IsTest
public class VFP_DoubleGroupingList_Controller_TEST {
    @testSetup static void setup() {
        List<Quote> lstQuote = new List<Quote>();
        Account objAccount = new Account(Name = 'Test Acc1', BillingCity = 'Test City', BillingState = 'Test State', 
                                         BillingStreet = 'Test Street', BillingPostalCode = '12345', 
                                         BillingCountry = 'Test Country', Phone = '123456');
        insert objAccount;
        
        Product2 objProduct = new Product2(Name = 'Test product1', family = 'Cafe');
        insert objProduct;
        
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        
        Opportunity objOpp = new Opportunity(Name = 'Test Opp', AccountId = objAccount.Id, StageName = 'Verbal Confirmation', CloseDate = Date.today()+1);
        insert objOpp;
        
        Quote q = new Quote(OpportunityId = objOpp.Id, Name = 'Test Quote', Pricebook2Id = Test.getStandardPricebookId(),
                            Status = 'Review Pending');     
        insert q;
        
        List<QuoteLineItem> quoteLineList = new List<QuoteLineItem>();
        List<String> possibleTypes = new List<String>{'brand new', 'used', 'never used'};
        List<String> possibleSubtypes = new List<String>{'broken', 'never tested', 'working'};


        for(Integer i=0; i<3; i++) { 
            for(Integer j=0; j<3; j++) { 
                QuoteLineItem qli = new QuoteLineItem ();
                qli = new QuoteLineItem(quoteId = q.Id, Quantity = 1, UnitPrice = 7500, 
                                        PricebookEntryId = objPBE.Id, Product2Id = objProduct.Id,
                                        Description = 'quote line item n.'+i+'0'+j,
                                        type_test__c = possibleTypes[i],subtype_test__c = possibleSubtypes[j]);
                quoteLineList.add(qli);
            }
        }
        insert quoteLineList;
    }
    
    @IsTest
    static void makeQuoteLineItemGroupingsMap_Test() {
        Id quoteId = [SELECT Id FROM Quote LIMIT 1].Id;
        ApexPages.currentPage().getParameters().put('id', quoteId);
        System.debug('quoteId: '+quoteId);
        VFP_DoubleGroupingList_Controller ctrl = new VFP_DoubleGroupingList_Controller();        
        //Map<String, Map<String, List<QuoteLineItem>>> result = ctrl.makeQuoteLineItemGroupingsMap(quoteId);
        Map<String, Map<String, List<QuoteLineItem>>> result = ctrl.dataMap;
        System.assertEquals('quote line item n.202', result.get('never used').get('working')[0].Description);
        System.debug('result : ' + result);
    }
    
    
    /*
@IsTest
static void Wr_oneTable_Test() {
VFP_DoubleGroupingList_Controller.Wr_oneTable oneTable = new VFP_DoubleGroupingList_Controller.Wr_oneTable();
}
@IsTest
static void Wr_oneGrouping_Test() {
VFP_DoubleGroupingList_Controller.Wr_oneGrouping oneGrouping = new VFP_DoubleGroupingList_Controller.Wr_oneGrouping();
}
@IsTest
static void Wr_oneSubGrouping_Test() {
VFP_DoubleGroupingList_Controller.Wr_oneSubGrouping oneSubGrouping = new VFP_DoubleGroupingList_Controller.Wr_oneSubGrouping();
}
@IsTest
static void Wr_oneRow_Test() {
VFP_DoubleGroupingList_Controller.Wr_oneRow oneRow = new VFP_DoubleGroupingList_Controller.Wr_oneRow();
}
@IsTest
static void Wr_oneData_Test() {
VFP_DoubleGroupingList_Controller.Wr_oneData oneData = new VFP_DoubleGroupingList_Controller.Wr_oneData();
}
@IsTest
static void Wr_oneGroupingTotal_Test() {
VFP_DoubleGroupingList_Controller.Wr_oneGroupingTotal oneGroupingTotal = new VFP_DoubleGroupingList_Controller.Wr_oneGroupingTotal();
}
@IsTest
static void Wr_oneSubGroupingTotal_Test() {
VFP_DoubleGroupingList_Controller.Wr_oneSubGroupingTotal oneSubGroupingTotal = new VFP_DoubleGroupingList_Controller.Wr_oneSubGroupingTotal();
}
*/ 
}