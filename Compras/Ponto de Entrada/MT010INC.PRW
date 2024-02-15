USER FUNCTION MT010INC()
	//PE ACIONADO PELO (MVC) User Function ITEM()
	//////////////////////////////////////////////////////////////////////////
	///  Inclusao Integração Z10 Maximo - Everton Forti 			       ///
	//   MXITEM - GRAVA Z10 EM TODAS EMPRESAS                               ///
	//////////////////////////////////////////////////////////////////////////
	//ALERT("ENTROU NO PONTO DE ENTRADA")

	LOCAL xEmp 		:= SuperGetMV("MV_UFILMX",.F.,"")
	Local aArea 	:= GetArea()
	Local aAreaSB1  := SB1->(GetArea())   	
	Local cMsg
	xEmp := SuperGetMv("MV_UFILMX",.F.,"")

	IF cNumemp $ xEmp //1
	
	cMsg := "Integrar com Maximo esta ."
	cMsg += "Inclusão " 
	
	IF MsgYesNo(cMsg,  " Continua?")
	

	IF M->B1_UINTMAX == "S"
		DBSELECTAREA("Z10")
		IF RecLock("Z10",.t.)                                                      
			Z10->Z10_FILIAL   := XFilial("Z10")                                     
			Z10->Z10_INREG 	  := "SB1"                                               
			Z10->Z10_DATA 	  := DATE()                                              
			Z10->Z10_USUARI   :=  RetCodUsr()                                        
			Z10->Z10_HORA  	  := time()                                              
			Z10->Z10_MOVIME	  := '3' //Inclusao                                      
			Z10->Z10_B1COD 	  := SB1->B1_COD        
			Z10->Z10_B1DESC	  := SB1->B1_DESC       
			Z10->Z10_B1UM  	  := SB1->B1_UM         
			Z10->Z10_LOCAL    := SB1->B1_LOCPAD                               
			Z10->Z10_ORIGEM	  := "MATA010"                                           
			Z10->Z10_DESTIN	  := "MXITEM"                                            
			Z10->Z10_UGERTA   := SB1->B1_UGERTAG           //Gera TAG              
			Z10->Z10_UTIPMA   := SB1->B1_UTIPMAT           //Tip Material          
			Z10->Z10_UINDEF   := SB1->B1_UINDEFI           //Eficiencia            
			Z10->Z10_UINDVU   := SB1->B1_UINDVU            //Vida Util             
			Z10->Z10_ULPDTP   := SB1->B1_ULPDTP            //Tp Lampada            
			Z10->Z10_ULPDPO   := SB1->B1_ULPDPOT           //Pot. Watts            
			Z10->Z10_ULPDEF   := SB1->B1_ULPDEFI           //Eficiencia            
			Z10->Z10_ULPDVU   := SB1->B1_ULPDVU            //Vida Util             
			Z10->Z10_ULUMTP   := SB1->B1_ULUMTP            //Tp Luminaria          
			Z10->Z10_ULUMPO   := SB1->B1_ULUMPOT           //Pot. Watts            
			Z10->Z10_ULUMEF   := SB1->B1_ULUMEFI           //Eficiencia            
			Z10->Z10_ULUMVU   := SB1->B1_ULUMVU            //Vida Util             
			Z10->Z10_UREATP   := SB1->B1_UREATP            //Tp Reator             
			Z10->Z10_UREAPO   := SB1->B1_UREAPOT           //Pot. Watts            
			Z10->Z10_UREAEF   := SB1->B1_UREAEFI           //Eficiencia            
			Z10->Z10_UREAVU   := SB1->B1_UREAVU            //Vida Util               
			Z10->Z10_UPOSTP   := SB1->B1_UPOSTP            //Tp Poste                
			Z10->Z10_UBRCTP   := SB1->B1_UBRCTP            //Tp Braco                
			Z10->Z10_USUPTP   := SB1->B1_USUPTP            //Tp Suporte              
			Z10->Z10_UPRJTP   := SB1->B1_UPRJTP            //Tp Projetor             
			Z10->Z10_UPRJEF   := SB1->B1_UPRJEFI           //Eficiencia              
			Z10->Z10_UVENTP   := SB1->B1_UVENTP            //Tp Ventilado            
			Z10->Z10_UVENPO   := SB1->B1_UVENPOT           //Pot. Watts              
			Z10->Z10_UACDTP   := SB1->B1_UACDTP            //Tp Ar-Condic            
			Z10->Z10_UACDPO   := SB1->B1_UACDPOT           //Pot. Watts              
			Z10->Z10_UACDPT   := SB1->B1_UACDPT            //Pot. Termica            
			Z10->Z10_UAQSVO   := SB1->B1_UAQSVOL           //Vol. Boiler             
			Z10->Z10_UAQSPO   := SB1->B1_UAQSPOT           //Pot. Watts              
			Z10->Z10_UAQSAR   := SB1->B1_UAQSARE           //Area Coletor            
			Z10->Z10_UAQSPE   := SB1->B1_UAQSPEC           //Prod Energia            
			Z10->Z10_UCHUEF   := SB1->B1_UCHUEFI           //Eficiencia              
			Z10->Z10_UCHUPO   := SB1->B1_UCHUPOT           //Pot. Watts              
			Z10->Z10_UBOMPO   := SB1->B1_UBOMPOT           //Pot. Watts              
			Z10->Z10_URELTP   := SB1->B1_URELTP            //Tp Rele                 
			Z10->Z10_URELVU   := SB1->B1_URELVU            //Vida Util               
			Z10->Z10_UDIASG   := SB1->B1_UDIASGA           //Dias Garanti            
			Z10->Z10_UINTMA   := SB1->B1_UINTMAX           //Int.Maximo              
			Z10->Z10_TIPPRO   := SB1->B1_UTIPPRO           //tipo produto            
			Z10->Z10_INDPO    := SB1->B1_UINDPO           //Indicador potencia       
			Z10->Z10_INDPT    := SB1->B1_UINDPT           //Indicador potencia termic
			Z10->Z10_ARCGIS   := SB1->B1_ARCGIS           //Gera ARCGIS              
			MsUnlock()
		ENDIF                                                               
	ENDIF	
	ENDIF
ENDIF

	RestArea( aArea )
	RestArea( aAreaSB1 )
Return .T.
