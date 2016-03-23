public class AddProductsExtension
{
    Apexpages.StandardController controller;
    Pricebook2 standardBook; 
    OpportunityLineItem oli;
    public String currentId {get;set;}
    
    public AddProductsExtension(ApexPages.StandardController c) {
    
        currentId = ApexPages.currentPage().getParameters().get('addTo');
        system.debug('Id' +currentId);
        controller = c;  

    }
   

    public Date startDate{get; set;}
    public Integer period{get; set;}
    public List<Product2> Stdproduct{get;set;}
    public List<wrapper> wrapperList {get;set;} 
    public list<wrapper> SelectedprodList{get;set;}
    public list<wrapper> CheckprodList{get;set;}
    public list<wrapper> CalcprodList {get; set;}
    public list<OpportunityLineItem> oppoLineList = new list<OpportunityLineItem>();
    //public Integer periPrice{get; set;}
    //public integer quantity{get;set;}
    
    
       
    public class wrapper
    {
        public product2 prod{get;set;}
        public Boolean selected{get;set;}
        Public Date start{get; set;}    
        Public Integer periods{get; set;}
        Public Date ends{get; set;}
        Public Integer pPrice {get; set;}
        Public Integer Units {get; set;}
        public integer unitPrice{get; set;}
        public integer totalPrice{get; set;}
        
        public wrapper(product2 p)
        {
            prod = p;
            selected = false;
            start = NULL;
            ends = NULL;
            periods = 0;
            unitPrice = 0;
            
        }
    }

    
    public List<wrapper> getproducts()
    {
         if(wrapperList == null || (wrapperList.size() == 0))
         {
             wrapperList = new List<wrapper>();
             Stdproduct = [select Id,Name , ProductCode , Description ,Family from product2];          
             for(Product2 p :(List<Product2>)Stdproduct)           
             {              
                 wrapperList.add(new wrapper(p));
             }        
         } 
          return wrapperList;
    }
    
    public list<wrapper> getSelectedproducts()
    {
        selectedprodList = new list<wrapper>();
             
        for(wrapper cCon: getproducts())
        {       
            if(cCon.selected==true) 
            {                          
                selectedprodList.add(cCon);     
            }                          
        }
        return selectedprodList;            
    } 
    
    public void reCalculate()
    {       
        selectedprodList.clear();
 
        for(wrapper cCon:  getproducts())
        {  
            cCon.start = startDate;
            cCon.periods = period;
            cCon.ends = startDate + (period*365);
            selectedprodList.add(cCon);                
        }    
    }
    
    public pageReference save() 
    {
        system.debug('Inside save-->' +selectedprodList);
        
        map<String,ID> pbEntry = new  map<String,ID>();
        
        Pricebook2 newPriceBook = new Pricebook2 ();
        newPriceBook.Name = 'New Price Book';
        insert newPriceBook;
        
        /*standardBook = [SELECT Id FROM Pricebook2 WHERE IsStandard = true];
        system.debug(standardBook);*/
        
        Opportunity temp = [select Pricebook2Id from opportunity where id=:currentId limit 1];
        temp.Pricebook2Id =  newPriceBook.id;
        update temp;
        
        list<pricebookEntry> pbList = new  list<pricebookEntry>();
        for(wrapper w : selectedprodList)
        {
            pricebookEntry priceEntry = new pricebookEntry();
            priceEntry.Pricebook2ID = newPriceBook.id;
            priceEntry.UnitPrice=0;
            priceEntry.Product2ID = w.prod.id;
            priceEntry.UseStandardPrice = false;
            priceEntry.IsActive = true;
            pbList.add(priceEntry);
        
        }
        insert(pbList);     
        
        list<pricebookEntry> insertedList = new list<pricebookEntry>([select id, name from pricebookEntry where Pricebook2ID =:newPriceBook.id]);
 
        for(pricebookEntry p : insertedList )
        {
            pbEntry.put(p.name,p.id);
        } 
        
        for(wrapper w : selectedprodList)
        {
            oli = new OpportunityLineItem();
            oli.OpportunityID = currentId ;
            oli.PricebookEntryId = pbEntry.get(w.prod.name);
            oli.Period__c = w.periods;
            oli.Start_Date__c = w.start;
            oli.End_Date__c = w.ends;
            oli.Periodic_Price__c = w.pPrice;
            oli.Single_Unit_Price__c = w.unitPrice;
            oli.Quantity = w.Units ;
            oli.TotalPrice = w.Units * w.unitPrice;
            
            oppoLineList.add(oli); 
        }
        insert(oppoLineList);
        string url = '/'+currentId;
        PageReference newpage=new PageReference(url);
        return newpage;
     }
 
}