public class VFP_DoubleGroupingList_Controller {
    
    
    /* IDEAS
* generate lists of existing groupings from dataMap's keysets to create columns
*/
    
    
    
    
    
    public string currentQuoteId{get;set;}
    public Quote currentQuote{get;set;}
    public List<List<QuoteLineItem>> firstGroupings{get;set;} 
    public Map<String, Map<String, List<QuoteLineItem>>> dataMap{get;set;} 
    
    public String getAccessJsonMap() {
        return JSON.serialize(dataMap);
    }
    
    public final List<QuoteLineItem> allQuoteLineItems;
    
    public VFP_DoubleGroupingList_Controller() {
        
        System.debug('>>>>> START VFP_DoubleGroupingList_Controller CONSTRUCTOR');
        
        firstGroupings = new List<List<QuoteLineItem>>();
        
        currentQuoteId = ApexPages.currentPage().getParameters().get('id');
        if(currentQuoteId == null || currentQuoteId == 'undefined' || currentQuoteId == '') {
        	currentQuoteId = '0Q01n000001hb01';    
        }
        
        
        currentQuote = [SELECT Id, Name, 
                        (SELECT Id, quote.Name, Description, type_test__c, subtype_test__c, fakedata1__c, fakedata2__c, fakedata3__c, fakedata4__c, fakedata5__c 
                         FROM QuoteLineItems ORDER BY type_test__c, subtype_test__c) 
                        FROM Quote WHERE id = :currentQuoteId];        
        System.debug('currentQuote query : SELECT Id, Name, (SELECT Id, Description, type_test__c, subtype_test__c, fakedata1__c, fakedata2__c, fakedata3__c, fakedata4__c, fakedata5__c FROM QuoteLineItems ORDER BY type_test__c, subtype_test__c) FROM Quote WHERE id = '+currentQuoteId);
        
        allQuoteLineItems = currentQuote.quoteLineItems;        
        System.debug('currentQuote : ' + allQuoteLineItems);
        dataMap = makeQuoteLineItemGroupingsMap(currentQuoteId);
        System.debug('<<<<<< END VFP_DoubleGroupingList_Controller CONSTRUCTOR');  
        
    }
    
    
    
    
    // Gets and groups QuoteLineItems first by the type_test__c field then by the subtype_test__c field
    // Returns a Map<String, Map<String, List<QuoteLineItem>>>
    // as: Map<type_test__c, Map<subtype_test__c, List<QuoteLineItem>>>
    public Map<String, Map<String, List<QuoteLineItem>>> makeQuoteLineItemGroupingsMap(Id currentQuoteId) {
        
        currentQuote = [SELECT Id, Name, 
                        (SELECT Id, quote.Name, Description, type_test__c, subtype_test__c, fakedata1__c, fakedata2__c, fakedata3__c, fakedata4__c, fakedata5__c 
                         FROM QuoteLineItems ORDER BY type_test__c, subtype_test__c) 
                        FROM Quote WHERE id = :currentQuoteId];        
        System.debug('currentQuote query : SELECT Id, Name, (SELECT Id, Description, type_test__c, subtype_test__c, fakedata1__c, fakedata2__c, fakedata3__c, fakedata4__c, fakedata5__c FROM QuoteLineItems ORDER BY type_test__c, subtype_test__c) FROM Quote WHERE id = '+currentQuoteId);
        
        List<QuoteLineItem> qts = currentQuote.quoteLineItems;        
        System.debug('currentQuote : ' + allQuoteLineItems);
        
        
        System.debug('>>>>> START VFP_DoubleGroupingList_Controller makeQuoteLineItemGroupingsMap(qlis)');
        Map<String, Map<String, List<QuoteLineItem>>> dataMap = new Map<String, Map<String, List<QuoteLineItem>>>();        
        Map<String, List<QuoteLineItem>> typesQliMap = new Map<String, List<QuoteLineItem>>();
        Map<String, List<QuoteLineItem>> typesToSubtypesQliMap = new Map<String, List<QuoteLineItem>>();
        
        // get all possible firstGroupings names from field definition
        List<String> possibleFirstGroupings = new List<String>();
        Schema.DescribeFieldResult fieldResultType = QuoteLineItem.type_test__c.getDescribe();
        List<Schema.PicklistEntry> pleType = fieldResultType.getPicklistValues();        
        for( Schema.PicklistEntry f : pleType) {
            possibleFirstGroupings.add(f.getValue());
        }
        System.debug('-> possibleFirstGroupings : ' + possibleFirstGroupings);        
        
        // get all possible subGroupings names
        List<String> possibleSubGroupings = new List<String>();
        Schema.DescribeFieldResult fieldResultSubType = QuoteLineItem.subtype_test__c.getDescribe();
        List<Schema.PicklistEntry> pleSubType = fieldResultSubType.getPicklistValues();        
        for( Schema.PicklistEntry f : pleSubType) {
            possibleSubGroupings.add(f.getValue());
        }
        System.debug('-> possibleSubGroupings : ' + possibleSubGroupings); 
        
        
        System.debug('\n/ / / / / / '); 
        System.debug('-> Grouping by TYPE (type_test__c)');        
        // for each existing first grouping, isolate ALL the corresponding quoteLineItems 
        for(String oneType : possibleFirstGroupings) {            
            System.debug('-> current oneGroupingName : ' + oneType);
            String tempTypeSortingName = oneType;
            List<QuoteLineItem> tempSortingListByType = new List<QuoteLineItem>();
            for(QuoteLineItem oneQteLi : qts) {
                if(oneType.equalsIgnoreCase(oneQteLi.type_test__c)) {
                    tempSortingListByType.add(oneQteLi);
                    //System.debug('oneQteLi : '+oneQteLi);
                }
            }
            typesQliMap.put(tempTypeSortingName,tempSortingListByType);
            
        }
        System.debug('makeQuoteLineItemGroupingsMap typesQliMap : ' + typesQliMap); 
        
        System.debug('\n/ / / / / / '); 
        
        
        for(String oneGroupingName : typesQliMap.keyset()) {            
            System.debug('-> Grouping by SUBTYPE (subtype_test__c');
            System.debug('-> current oneGroupingName : ' + oneGroupingName);
            
            typesToSubtypesQliMap = new Map<String, List<QuoteLineItem>>();
            List<QuoteLineItem> oneTypeQliList = typesQliMap.get(oneGroupingName);
            List<QuoteLineItem> tempSortingListBySubType = new List<QuoteLineItem>();
            System.debug('-> possible subTypes : '+ possibleSubGroupings);
            
            for(String oneSubType : possibleSubGroupings) {
                tempSortingListBySubType = new List<QuoteLineItem>();                
                System.debug('-> current oneSubType : ' + oneSubType);
                for(QuoteLineItem oneQteLi : oneTypeQliList) {                    
                    if(oneSubType.equalsIgnoreCase(oneQteLi.subtype_test__c) && 
                       oneGroupingName.equalsIgnoreCase(oneQteLi.type_test__c)) {
                           tempSortingListBySubType.add(oneQteLi);
                       }
                }
                
                System.debug('-> tempSortingListBySubType : '+ tempSortingListBySubType);
                typesToSubtypesQliMap.put(oneSubType, tempSortingListBySubType);          
                
            }   
            
            System.debug('-> current oneGroupingName : ' + oneGroupingName);
            System.debug('-> associated map: ' + typesToSubtypesQliMap);
            dataMap.put(oneGroupingName, typesToSubtypesQliMap);
        }
        
        
        System.debug('-> dataMap : ' + dataMap);
        System.debug('<<<<<< END  VFP_DoubleGroupingList_Controller makeQuoteLineItemGroupingsMap END');
        return dataMap;
    }
    
    
    
    
    
    // Maybe use wrappers for totals and subtotals ?
    /*
public class Wr_oneTable {
public List<Wr_oneGrouping> oneTable{get;set;}
}
public class Wr_oneGrouping {
// contains MANY subGroupings and ONE groupingTotal
public String                   oneGroupingLabel{get;set;}
public List<Wr_oneSubGrouping>  oneGrouping{get;set;}
public Wr_oneGroupingTotal      oneGroupingTotal{get;set;}        

// may be used for the "OPTIONS" quoteLineItems
public List<Wr_oneRow> optionsList{get;set;}
}
public class Wr_oneSubGrouping {
// contains MANY rows and ONE subGroupingTotal
public String                   oneSubGroupingLabel{get;set;}
public List<Wr_oneRow>          oneSubGrouping{get;set;}
public Wr_oneSubGroupingTotal   oneSubGroupingTotal{get;set;}
}
public class Wr_oneRow {
public Wr_oneRow() {}
public Wr_oneRow(QuoteLineItem qli) {
this.oneQuoteLineItem = qli;
}
public QuoteLineItem                oneQuoteLineItem{get;set;}
public List<Wr_oneData>     oneRow{get;set;}
}
public class Wr_oneData {
public String   strDataOne{get;set;}
public String   strDataTwo{get;set;}
public Integer  intDataOne{get;set;}
public String   strDataThree{get;set;}
public Integer  intDataTwo{get;set;}
}

public class Wr_oneGroupingTotal {
public String   strOne{get;set;} //firstname
public String   strTwo{get;set;} //lastname
public Integer  intOne{get;set;} //age__c
public String   strThree{get;set;} // Title
public Integer  intTwo{get;set;} //age__c again, fuck it
}
public class Wr_oneSubGroupingTotal {
public Integer  intOne{get;set;} //age__c total
public Integer  intTwo{get;set;} //age__c again, fuck it
}

*/
    
    
    
    
    
    
    
    
    
    
}