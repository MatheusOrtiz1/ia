#include "rwmake.ch"
#include "TOPCONN.CH"
#include "CTBR510.CH"
//#include "CTBXSAL.CH"


Static Function lCTGerPlan(oMeter,oText,oDlg,lEnd,cArqtmp,dDataIni,dDataFim,cAlias,cIdent,cContaIni,;
						cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,;
						cClVlFim,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,;
						cSegFim,cFiltSegm,lNImpMov,lImpConta,nGrupo,cHeader,lImpAntLP,dDataLP,;
						nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,;
						cSegmentoG,cSegIniG,cSegFimG,cFiltSegmG,lUsGaap,cMoedConv,;
						cConsCrit,dDataConv,nTaxaConv,aGeren,lImpMov,lImpSint,cFilUSU,lRecDesp0,;
						cRecDesp,dDtZeraRD)
						
Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamCtaRes	:= TAMSX3("CT1_RES")
Local aTamCC        := TAMSX3("CTT_CUSTO")
Local aTamCCRes 	:= TAMSX3("CTT_RES")
Local aTamItem  	:= TAMSX3("CTD_ITEM")
Local aTamItRes 	:= TAMSX3("CTD_RES")    
Local aTamClVl  	:= TAMSX3("CTH_CLVL")
Local aTamCvRes 	:= TAMSX3("CTH_RES")
Local aCtbMoeda		:= {}
Local aSaveArea 	:= GetArea()
Local aCampos
//Local aSaldoAnt
//Local aSaldoAtu
Local aStruTmp		:= {}
Local cChave
Local nTamCta 		:= Len(CriaVar("CT1_DESC"+cMoeda))
Local nTamItem		:= Len(CriaVar("CTD_DESC"+cMoeda))
Local nTamCC  		:= Len(CriaVar("CTT_DESC"+cMoeda))
Local nTamClVl		:= Len(CriaVar("CTH_DESC"+cMoeda))
Local nTamGrupo		:= Len(CriaVar("CT1_GRUPO"))
Local nDecimais		:= 0
Local cEntidIni		:= ""
Local cEntidFim		:= ""           
Local cEntidIni1	:= ""
Local cEntidFim1	:= ""
Local cEntidIni2	:= ""
Local cEntidFim2	:= ""
Local cArqTmp1		:= ""
Local lCusto		:= CtbMovSaldo("CTT")//Define se utiliza C.Custo
Local lItem 		:= CtbMovSaldo("CTD")//Define se utiliza Item
Local lClVl			:= CtbMovSaldo("CTH")//Define se utiliza Cl.Valor 
Local lAtSldBase	:= Iif(GetMV("MV_ATUSAL")== "S",.T.,.F.) 
Local lAtSldCmp		:= Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)
Local nInicio		:= Val(cMoeda)
Local nFinal		:= Val(cMoeda)
Local nTrb			:= 0
Local cFilDe		:= xFilial(cAlias)
Local cFilAte		:= xFilial(cAlias), nOrdem := 1
Local cCodMasc		:= ""
Local cMensagem		:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio. 
Local nCampoLP		:= 0
Local nPos			:= 0
Local lTemQry		:= .F.
Local nDigitos		:= 0
Local nMeter		:= 0
Local nMin			:= 0
Local nMax			:= 0
/*private cSegmentoG 	:= ""
private lUsGaap		:=.F.
private cMoedConv	:= ""
private	cConsCrit	:= ""
private dDataConv	:= CTOD("  /  /  ")
private nTaxaConv	:= 0
private lImpSint	:= .T.                                              
private lImpMov		:= .T.
private cSegmento	:= ""
private cFilUsu		:= ".T."
private lRecDesp0	:= .F.
private cRecDesp 	:= ""                
private dDtZeraRD	:= CTOD("  /  /  ")*/

cIdent		:=	Iif(cIdent == Nil,'',cIdent)
nGrupo		:=	Iif(nGrupo == Nil,2,nGrupo)                                                 
cHeader		:= Iif(cHeader == Nil,'',cHeader)
cFiltroEnt	:= Iif(cFiltroEnt == Nil,"",cFiltroEnt)
cCodFilEnt	:= Iif(cCodFilEnt == Nil,"",cCodFilEnt)

// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]
dMinData := CTOD("")

If cAlias == 'CTY'	//Se for Balancete de 2 Entidades filtrando pela 3a Entidade.
	aCampos := {{ "ENTID1"		, "C", aTamConta[1], 0 },;  			// Codigo da Conta
				 { "ENTRES1"	, "C", aTamCtaRes[1],0 },;  			// Codigo Reduzido da Conta
				 { "DESCENT1"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
	 			 { "TIPOENT1"  	, "C", 01			, 0 },;				// Centro de Custo Analitico / Sintetico				 
 				 { "ENTSUP1"	, "C", aTamCC[1]	, 0 },;				// Codigo do Centro de Custo Superior
	   	         { "ENTID2"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
				 { "ENTRES2"	, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
				 { "DESCENT2"	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
				 { "TIPOENT2"	, "C", 01			, 0 },;				// Item Analitica / Sintetica			 
				 { "ENTSUP2"	, "C", aTamItem[1]	, 0 },; 			// Codigo do Item Superior
		 		 { "NORMAL"		, "C", 01			, 0 },;				// Situacao
				 { "SALDOANT"	, "N", 17			, nDecimais},; 		// Saldo Anterior
	 		 	 { "SALDOANTDB"	, "N", 17			, nDecimais},; 		// Saldo Anterior Debito
			 	 { "SALDOANTCR"	, "N", 17			, nDecimais},; 		// Saldo Anterior Credito
			 	 { "SALDODEB"	, "N", 17			, nDecimais },;  	// Debito
				 { "SALDOCRD"	, "N", 17			, nDecimais },;  	// Credito
				 { "SALDOATU"	, "N", 17			, nDecimais },;  	// Saldo Atual               
				 { "SALDOATUDB"	, "N", 17			, nDecimais },;  	// Saldo Atual Debito
			     { "SALDOATUCR"	, "N", 17			, nDecimais },;  	// Saldo Atual Credito
				 { "MOVIMENTO"	, "N", 17			, nDecimais },;  	// Movimento do Periodo
				 { "ORDEM"		, "C", 10			, 0 },;				// Ordem
				 { "GRUPO"		, "C", nTamGrupo	, 0 },;				// Grupo Contabil
		    	 { "IDENTIFI"	, "C", 01			, 0 },;			 
			  	 { "NIVEL1"		, "L", 01			, 0 }}				// Logico para identificar se 
														 				// eh de nivel 1 -> usado como
																		// totalizador do relatorio]
				 
Else
	aCampos := { { "CONTA"		, "C", aTamConta[1], 0 },;  			// Codigo da Conta
				 { "SUPERIOR"	, "C", aTamConta[1], 0 },;				// Conta Superior
		 		 { "NORMAL"		, "C", 01			, 0 },;				// Situacao
				 { "CTARES"		, "C", aTamCtaRes[1], 0 },;  			// Codigo Reduzido da Conta
				 { "DESCCTA"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
				 { "CUSTO"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
				 { "CCRES"		, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
				 { "DESCCC" 	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
		         { "ITEM"		, "C", aTamItem[1]	, 0 },; 	 		// Codigo do Item          
				 { "ITEMRES" 	, "C", aTamItRes[1], 0 },;  			// Codigo Reduzido do Item
				 { "DESCITEM" 	, "C", nTamItem		, 0 },;  			// Descricao do Item
	             { "CLVL"		, "C", aTamClVl[1]	, 0 },; 	 		// Codigo da Classe de Valor
    	         { "CLVLRES"	, "C", aTamCVRes[1], 0 },; 		 	// Cod. Red. Classe de Valor
				 { "DESCCLVL"   , "C", nTamClVl		, 0 },;  			// Descricao da Classe de Valor
				 { "SALDOANT"	, "N", 17			, nDecimais},; 		// Saldo Anterior
	   		 	 { "SALDOANTDB"	, "N", 17			, nDecimais},; 		// Saldo Anterior Debito
 				 { "SALDOANTCR"	, "N", 17			, nDecimais},; 		// Saldo Anterior Credito
				 { "SALDODEB"	, "N", 17			, nDecimais },;  	// Debito
				 { "SALDOCRD"	, "N", 17			, nDecimais },;  	// Credito
				 { "SALDOATU"	, "N", 17			, nDecimais },;  	// Saldo Atual               
				 { "SALDOATUDB"	, "N", 17			, nDecimais },;  	// Saldo Atual Debito
				 { "SALDOATUCR"	, "N", 17			, nDecimais },;  	// Saldo Atual Credito
				 { "MOVIMENTO"	, "N", 17			, nDecimais },;  	// Movimento do Periodo
				 { "TIPOCONTA"	, "C", 01			, 0 },;				// Conta Analitica / Sintetica           
 				 { "TIPOCC"  	, "C", 01			, 0 },;				// Centro de Custo Analitico / Sintetico
	 			 { "TIPOITEM"	, "C", 01			, 0 },;				// Item Analitica / Sintetica			 
 				 { "TIPOCLVL"	, "C", 01			, 0 },;				// Classe de Valor Analitica / Sintetica			 
	 			 { "CCSUP"		, "C", aTamCC[1]	, 0 },;				// Codigo do Centro de Custo Superior
				 { "ITSUP"		, "C", aTamItem[1]	, 0 },;				// Codigo do Item Superior
	 			 { "CLSUP"	    , "C", aTamClVl[1] , 0 },;				// Codigo da Classe de Valor Superior
				 { "ORDEM"		, "C", 10			, 0 },;				// Ordem
				 { "GRUPO"		, "C", nTamGrupo	, 0 },;				// Grupo Contabil
			     { "IDENTIFI"	, "C", 01			, 0 },;			 
   			     { "ESTOUR" 	, "C", 01			, 0 },;			 	//Define se a conta esta estourada ou nao
				 { "NIVEL1"		, "L", 01			, 0 }}				// Logico para identificar se 
																		// eh de nivel 1 -> usado como
																		// totalizador do relatorio]

// Usado no mutacoes de patrimonio liquido inclui campo que alem da descricao da entidade
// Que esta no DESCCTA tem tambem a descricao da conta inicial CTS_CT1INI
																			
	If 	Type("lTRegCts") # "U" .And. ValType(lTRegCts) = "L" .And. lTRegCts
		Aadd(aCampos, { "DESCORIG"	, "C", nTamCta		, 0 } )	// Descricao da Origem do Valor
	Endif
EndIf

If CTS->(FieldPos("CTS_COLUNA")) > 0
	Aadd(aCampos, { "COLUNA"   	, "N", 01			, 0 })
Endif
			
If 	Type("dSemestre") # "U" .And. ValType(dSemestre) = "D"
	Aadd(aCampos, { "SALDOSEM"	, "N", 17		, nDecimais }) 	// Saldo semestre
Endif

If Type("dPeriodo0") # "U" .And. ValType(dPeriodo0) = "D"
	Aadd(aCampos, { "SALDOPER"	, "N", 17		, nDecimais }) 	// Saldo Periodo determinado
	Aadd(aCampos, { "MOVIMPER"	, "N", 17		, nDecimais }) 	// Saldo Periodo determinado
Endif

If Type("lComNivel") # "U" .And. ValType(lComNivel) = "L"
	Aadd(aCampos, { "NIVEL"   	, "N", 01			, 0 })		// Nivel hieraquirco - Quanto maior mais analitico
Endif	

If cAlias = "CT7" .And. SuperGetMv("MV_CTASUP") = "S"
	Aadd(aCampos, { "ORDEMPRN" 	, "N", 06			, 0 })		// Ordem para impressao
Endif

///// TRATAMENTO PARA ATUALIZAÇÃO DE SALDO BASE
//Se os saldos basicos nao foram atualizados na dig. lancamentos
If !lAtSldBase
  	#IFDEF TOP
		If TcSrvType() != "AS/400"                     		  	
			//Chama Rotina de Atualizacao de Saldos Basicos.
			oProcess := MsNewProcess():New({|lEnd|	Ct190SlBse(nInicio,nFinal,lClvl,lItem,lCusto,cSaldos,.T.,cFilDe,cFilAte,,,.T.,oProcess,nMin,nMax)},"","",.F.)
			oProcess:Activate()						
		Else
	#ENDIF
		oProcess := MsNewProcess():New({|lEnd|	Ct360RDbf(nInicio,nFinal,lClVl,lItem,lCusto,cSaldos,oProcess,lAtSldBase)},"","",.F.)		
		oProcess:Activate()						
	#IFDEF TOP
		EndIf
	#ENDIF
Endif	

//// TRATAMENTO PARA ATUALIZAÇÃO DE SALDOS COMPOSTOS ANTES DE EXECUTAR A QUERY DE FILTRAGEM
Do Case
Case cAlias == 'CTU'
	//Verificar se tem algum saldo a ser atualizado por entidade
	If cIdent == "CTT"
		cOrigem := 	'CT3'
	ElseIf cIdent == "CTD"
		cOrigem := 	'CT4'
	ElseIf cIdent == "CTH"
		cOrigem := 	'CTI'		
	Else
		cOrigem := 	'CTI'		
	Endif
Case cAlias == 'CTV'
	cOrigem := "CT4"
	//Verificar se tem algum saldo a ser atualizado
Case cAlias == 'CTW'			
	cOrigem		:= 'CTI'	/// HEADER POR CLASSE DE VALORES
	//Verificar se tem algum saldo a ser atualizado
Case cAlias == 'CTX'			
	cOrigem		:= 'CTI'		
EndCase	
              
IF cAlias$("CTU/CTV/CTW/CTX")
	Ct360Data(cOrigem,cAlias,@dMinData,lCusto,lItem,cFilDe,cFilAte,cSaldos,cMoeda,cMoeda,,,,,,,,,,cFilAnt)
	If lAtSldCmp .And. !Empty(dMinData)	//Se atualiza saldos compostos
		oProcess := MsNewProcess():New({|lEnd|	CtAtSldCmp(oProcess,cAlias,cSaldos,cMoeda,dDataIni,cOrigem,dMinData,cFilDe,cFilAte,lCusto,lItem,lClVl,lAtSldBase,,,cFilAnt)},"","",.F.)
		oProcess:Activate()	
	Else		//Se nao atualiza os saldos compostos, somente da mensagem
		If !Empty(dMinData)
			cMensagem	:=  "Nao achei" //STR0016
			cMensagem	+= "sem chance" //STR0017		
			MsgAlert(OemToAnsi(cMensagem),"Atenção")	//Os saldos compostos estao desatualizados...Favor atualiza-los					
			Return							//atraves da rotina de saldos compostos	
		EndIf    
	EndIf	
Endif

Do Case
Case cAlias  == "CT7"            
	cEntidIni	:= cContaIni
	cEntidFim	:= cContaFim
	cCodMasc		:= aSetOfBook[2]
	If nGrupo == 2
		cChave := "CONTA"
	Else									// Indice por Grupo -> Totaliza por grupo
		cChave := "CONTA+GRUPO"
	EndIf
	#IFDEF TOP   
		If TcSrvType() != "AS/400" //.And. u_CtbOracleV()
			//Se nao tiver plano gerencial. 
			If Empty(aSetOfBook[5])
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT7BlnQry(dDataIni,dDataFim,cAlias,cEntidIni,cEntidFim,cMoeda,;
							cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUsu)						
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif						
			Endif
		EndIf
	#ENDIF
Case cAlias == 'CT3'    
	cEntidIni	:= cCCIni
	cEntidFim	:= cCCFim
	If cHeader == "CT1"
		cChave		:= "CONTA+CUSTO"
		cCodMasc	:= aSetOfBook[2]				
	Else
		If nGrupo == 2
			cChave   := "CUSTO+CONTA"                      
		Else									// Indice por Grupo -> Totaliza por grupo
			cChave := "CUSTO+CONTA+GRUPO"
		EndIf	
		cCodMasc		:= aSetOfBook[2]					
	Endif
	#IFDEF TOP
		If TcSrvType() != "AS/400" //.And. u_CtbOracleV()
			/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
			CT3BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,;
						cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP)						
		EndIf
	#ENDIF		
Case cAlias =='CT4' 
	cEntidIni	:= cItemIni
	cEntidFim	:= cItemFim
	If cHeader == "CT1"	//Se for for Balancete Conta x Item
		cChave	:= "CONTA+ITEM"
		cCodMasc		:= aSetOfBook[4]			
	Else
		cChave   := "ITEM+CONTA"	
		cCodMasc		:= aSetOfBook[2]					
	EndIf	
	#IFDEF TOP
		If TcSrvType() != "AS/400" //.And. u_CtbOracleV()
			/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
			CT4BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cItemIni,cItemFim,cMoeda,;
						cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP)						
		EndIf
	#ENDIF	
Case cAlias == 'CTI'     
	cEntidIni	:= cClVlIni
	cEntidFim	:= cClvlFim
	cChave   := "CLVL+CONTA"
Case cAlias == 'CTU'
	If cIdent == 'CTT'
		cEntidIni	:= cCCIni
		cEntidFim	:= cCCFim	
		cChave		:= "CUSTO"
		cCodMasc		:= aSetOfBook[6]		
	ElseIf cIdent == 'CTD'
		cEntidIni	:= cItemIni
		cEntidFim	:= cItemFim		
		cChave   := "ITEM"
		cCodMasc		:= aSetOfBook[7]		
	ElseIf cIdent == 'CTH'
		cEntidIni	:= cClVlIni
		cEntidFim	:= cClvlFim		
		cChave   := "CLVL"
		cCodMasc		:= aSetOfBook[8]		
	Endif
	#IFDEF TOP  
		If TcSrvType() != "AS/400" //.And. u_CtbOracleV()
			/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
			CTUBlnQry(dDataIni,dDataFim,cAlias,cIdent,cEntidIni,cEntidFim,cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu)						
			If Empty(cFilUSU)
				cFILUSU := ".T."
			Endif								
		EndIf
	#ENDIF	
Case cAlias == 'CTV'           
	If cHeader == 'CTT'
		cChave   := "CUSTO+ITEM"	
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTD'
		cChave   := "ITEM+CUSTO"	
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim	
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
	EndIf
Case cAlias == 'CTW'
	If cHeader	== 'CTT'
		cChave   := "CUSTO+CLVL"			
		cEntidIni1	:=	cCCIni
		cEntidFim1	:=	cCCFim 	            		
		cEntidIni2	:=	cClVlIni
		cEntidFim2	:=	cClVlFim		
	ElseIf cHeader == 'CTH'                
		cChave   := "CLVL+CUSTO"			
		cEntidIni1	:=	cClVlIni
		cEntidFim1	:=	cClVlFim
		cEntidIni2	:=	cCCIni
		cEntidFim2	:=	cCCFim 	
	EndIf	
Case cAlias == 'CTX'
	If cHeader == 'CTD'
		cChave  	 := "ITEM+CLVL"			
		cEntidIni1	:= 	cItemIni
		cEntidFim1	:= 	cItemFim
		cEntidIni2	:= 	cClVlIni
		cEntidFim2	:= 	cClVlFim		
	ElseIf cHeader == 'CTH'
		cChave  	 := "CLVL+ITEM"			
		cEntidIni1	:= 	cClVlIni
		cEntidFim1	:= 	cClVlFim			
		cEntidIni2	:= 	cItemIni 	
		cEntidFim2	:= 	cItemFim 	
	EndIf                                
Case cAlias	== 'CTY'
	cChave			:="ENTID1+ENTID2"
	If cHeader == 'CTT' .And. cFiltroEnt == 'CTD'	
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cClVlIni
		cEntidFim2	:= cClvlFim
	ElseIf cHeader == 'CTT' .And. cFiltroEnt == 'CTH'
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTD' .And. cFiltroEnt == 'CTT'
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim	
		cEntidIni2	:= cClVlIni
		cEntidFim2	:= cClVlFim	
	ElseIf cHeader == 'CTD' .And. cFiltroEnt == 'CTH'
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim	
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim		
	ElseIf cHeader == 'CTH' .And. cFiltroEnt == 'CTT'
		cEntidIni1	:= cClVlIni
		cEntidFim1	:= cClVlFim	
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim		
	ElseIf cHeader == 'CTH' .And. cFiltroEnt == 'CTD'
		cEntidIni1	:= cClVlIni
		cEntidFim1	:= cClVlFim	
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim					
	EndIf		
EndCase

If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	If cAlias = 'CTU'
		Do Case
		Case cIdent = 'CTT'
			cChave	:= "CUSTO"		
		Case cIdent = 'CTD'
			cChave	:= "ITEM"		
		Case cIdent = 'CTH'
			cChave	:= "CLVL"		
		EndCase	
	Else
	   cChave	:= "CONTA"
	EndIf	   
Endif

cArqTmp := CriaTrab(aCampos, .T.)

dbUseArea( .T.,, cArqTmp, "cArqTmp", .F., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice Temporario do Arquivo de Trabalho 1.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cArqInd	:= CriaTrab(Nil, .F.)

IndRegua("cArqTmp",cArqInd,cChave,,,OemToAnsi(STR0001))  //"Selecionando Registros..."

If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	cArqTmp1 := CriaTrab(, .F.)
	IndRegua("cArqTmp",cArqTmp1,"ORDEM",,,OemToAnsi(STR0001))  //"Selecionando Registros..."
Endif	

dbSelectArea("cArqTmp")
DbClearIndex()
dbSetIndex(cArqInd+OrdBagExt())

If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	dbSetIndex(cArqTmp1+OrdBagExt())
Endif
                  
#IFDEF TOP
	If TcSrvType() != "AS/400"   //.And. u_CtbOracleV()
		//// SE FOR DEFINIÇÃO TOP 
		If cAlias $ "CT3/CT4"  .Or. cAlias $ "CT7/CTU"		
			If Select("TRBTMP") > 0		/// E O ALIAS TRBTMP ESTIVER ABERTO (INDICANDO QUE A QUERY FOI EXECUTADA)			
				
				If !Empty(cSegmento)
					If Len(aSetOfBook) == 0 .or. Empty(aSetOfBook[1])
						Help("CTN_CODIGO")
						Return(cArqTmp)
					Endif
					dbSelectArea("CTM")
					dbSetOrder(1)
					If MsSeek(xFilial()+cCodMasc)
						While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cCodMasc
							nPos += Val(CTM->CTM_DIGITO)
							If CTM->CTM_SEGMEN == strzero(val(cSegmento),2)
								nPos -= Val(CTM->CTM_DIGITO)
								nPos ++
								nDigitos := Val(CTM->CTM_DIGITO)      
								Exit
							EndIf	
							dbSkip()
						EndDo	
					Else
						Help("CTM_CODIGO")
						Return(cArqTmp)
					EndIf	
				EndIf	
  				dbSelectArea("TRBTMP")
				aStruTMP := dbStruct()			/// OBTEM A ESTRUTURA DO TMP
	
				nCampoLP	 := Ascan(aStruTMP,{|x| x[1]=="SLDLPANTDB"})
				dbSelectArea("TRBTMP")
				If ValType(oMeter) == "O"
					oMeter:SetTotal(TRBTMP->(RecCount()))
					oMeter:Set(0)
				EndIf
				dbGoTop()						/// POSICIONA NO 1º REGISTRO DO TMP
	
				While TRBTMP->(!Eof())			/// REPLICA OS DADOS DA QUERY (TRBTMP) PARA P/ O TEMPORARIO EM DISCO
			
					//Se nao considera apuracao de L/P sera verificado na propria query
					dbSelectArea("TRBTMP")								
					If !lVlrZerado .And. lImpAntLP .And. nCampoLp > 0 
						If (SALDOANTDB - SLDLPANTDB) == 0 .And. (SALDOANTCR - SLDLPANTCR) == 0 .And. ;
							(SALDODEB-MOVLPDEB) == 0 .And. (SALDOCRD-MOVLPCRD) == 0					
							dbSkip()
							Loop				
						EndIf				
					EndIf					

				
					If cAlias == "CTU"              
						Do Case
						Case cIdent	== "CTT"
							cCodigo	:= TRBTMP->CUSTO
						Case cIdent	== "CTD"
							cCodigo	:= TRBTMP->ITEM
						Case cIdent	== "CTH"
							cCodigo	:= TRBTMP->CLVL					
						EndCase                   
					Else
						cCodigo	:= TRBTMP->CONTA
					EndIf
				
					If !Empty(cSegmento)
						If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
							If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) ) 
								dbSkip()
								Loop
							EndIf	
						Else
							If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
								Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
								dbSkip()
								Loop
							EndIf	
						Endif
					EndIf		
				
					If &("TRBTMP->("+cFILUSU+")")				
						RecLock("cArqTMP",.T.)
						For nTRB := 1 to Len(aStruTMP)
							Field->&(aStruTMP[nTRB,1]) := TRBTMP->&(aStruTMP[nTRB,1])			
							If Subs(aStruTmp[nTRB][1],1,6) $ "SALDODEB/SALDOCRD/SALDOANTDB/SALDOANTCR/SLDLPANTCR/SLDLPANTDB/MOVLPDEB/MOVLPCRD" .And. nDivide > 0 
								Field->&(aStruTMP[nTRB,1])	:=((TRBTMP->&(aStruTMP[nTRB,1])))/ndivide                   
							EndIf										
						Next                    
			
						If cAlias	== "CTU"            
							Do Case
							Case cIdent	== "CTT"
							    If Empty(TRBTMP->DESCCC)
									cArqTmp->DESCCC		:= TRBTMP->DESCCC01													    
							    EndIf						    
							Case cIdent == "CTD"
								If Empty(TRBTMP->DESCITEM)
									cArqTmp->DESCITEM	:= TRBTMP->DESCIT01							
								EndIf						
							Case cIdent == "CTH"
								If Empty(TRBTMP->DESCCLVL)							
									cArqTmp->DESCCLVL	:= TRBTMP->DESCCV01							
								EndIf						
							EndCase					
						Else
							If Empty(TRBTMP->DESCCTA)
								cArqTmp->DESCCTA	:= TRBTMP->DESCCTA01
							EndIf
				             
							If cAlias == "CT4"
								If Empty(TRBTMP->DESCITEM)
									cArqTmp->DESCITEM	:= TRBTMP->DESCIT01
								EndIf
							EndIf             				
						EndIf
				
						If nCampoLP > 0 
							cArqTmp->SALDOANTDB	:= SALDOANTDB - SLDLPANTDB
							cArqTmp->SALDOANTCR	:= SALDOANTCR - SLDLPANTCR
							cArqTmp->SALDODEB	:= SALDODEB - MOVLPDEB
							cArqTmp->SALDOCRD	:= SALDOCRD - MOVLPCRD
						EndIf					
				 		cArqTmp->SALDOANT	:= SALDOANTCR-SALDOANTDB
						cArqTmp->SALDOATUDB	:= SALDOANTDB+SALDODEB
						cArqTmp->SALDOATUCR	:= SALDOANTCR+SALDOCRD 				 	
						cArqTmp->SALDOATU	:= SALDOATUCR-SALDOATUDB			
						cArqTmp->MOVIMENTO	:= SALDOCRD-SALDODEB			
						
					    //Se imprime saldo anterior do periodo anterior zerado, verificar o saldo atual da data de zeramento.                
						If lRecDesp0 .And. Subs(TRBTMP->CONTA,1,1) $ cRecDesp		
							aSldRecDes	:= SaldoCT7(TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,'CTBXFUN',.F.)		
							nSldRDAtuD	:=	aSldRecDes[4] 
							nSldRDAtuC	:=	aSldRecDes[5]
							nSldAtuRD	:= nSldRDAtuC - nSldRDAtuD			
                                                
							cArqTmp->SALDOANT 	-= nSldAtuRD
							cArqTmp->SALDOANTDB	-=	nSldRDAtuD
							cArqTmp->SALDOANTCR -=	nSldRDAtuC 	
							cArqTmp->SALDOATU   -= nSldAtuRD
							cArqTmp->SALDOATUDB -=	nSldRDAtuD
							cArqTmp->SALDOATUCR -=	nSldRdAtuC			
						EndIf                        
						
						cArqTMP->(MsUnlock())				
					EndIf					
					TRBTMP->(dbSkip())
					If ValType(oMeter) == "O"
						nMeter++
				    	oMeter:Set(nMeter)				
				  EndIf
				Enddo

				dbSelectArea("TRBTMP")
				dbCloseArea()					/// FECHA O TRBTMP (RETORNADO DA QUERY)
				lTemQry := .T.
			Endif
		Endif
	EndIf
#ENDIF


dbSelectArea("cArqTmp")
dbSetOrder(1)

If cAlias $ 'CT3/CT4/CTI' //Se imprime CONTA+ ENTIDADE
	If !Empty(aSetOfBook[5])
		MsgAlert(cMensagem,"")	
		Return
	Else
		If cHeader == "CT1"	//Se for Balancete Conta/Entidade
			#IFNDEF TOP	//Se for top connect, atualiza sinteticas
				// Monta Arquivo Lendo Plano Padrao - especifico para conta/ENTIDADE
				CtEntConta(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cContaIni,;
							cContaFim,cEntidIni,cEntidFim,cMoeda,cSaldos,aSetOfBook,;
							cAlias,lCusto,lItem,lClvl,lAtSldBase,nInicio,nFinal,lImpAntLP,dDataLP,;
							nDivide,lVlrZerado,lNImpMov)	                       
			#ELSE
				If TcSrvType() == "AS/400" .Or.  TcSrvType() <> 'AS/400' //.And.  !u_CtbOracleV())                     								
					// Monta Arquivo Lendo Plano Padrao - especifico para conta/ENTIDADE
					CtEntConta(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cContaIni,;
							cContaFim,cEntidIni,cEntidFim,cMoeda,cSaldos,aSetOfBook,;
							cAlias,lCusto,lItem,lClvl,lAtSldBase,nInicio,nFinal,lImpAntLP,dDataLP,;
							nDivide,lVlrZerado,lNImpMov)	                       							
				EndIf
			#ENDIF
			//Atualizacao de sinteticas para codebase e topconnect			
			If lImpSint	//Se atualiza sinteticas
		 		CtCtEntSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda)							
		    EndIf			
		Else
			// Monta Arquivo Lendo Plano Padrao - especifico para conta/ENTIDADE
			CtContaEnt(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cContaIni,;
						cContaFim,cEntidIni,cEntidFim,cMoeda,cSaldos,aSetOfBook,nTamCta,;
						cSegmento,cSegIni,cSegFim,cFiltSegm,lNImpMov,cAlias,lCusto,;
						lItem,lClvl,lAtSldBase,nInicio,nFinal,cFilDe,cFilAte,lImpAntLP,dDataLP,;
						nDivide,lVlrZerado,cSegmentoG,cSegIniG,cSegFimG,cFiltSegmG)
		EndIf
	EndIf
Else	
	If cAlias $ 'CTU/CT7' .Or. (!Empty(aSetOfBook[5]) .And. Empty(cAlias))		//So Imprime Entidade ou demonstrativos
		If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
			// Monta Arquivo Lendo Plano Gerencial                                   
			// Neste caso a filtragem de entidades contabeis é desprezada!
			lCtbPlGeren(	oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,cAlias,;
						cIdent,lImpAntLP,dDataLP,lVlrZerado,cEntidIni,cEntidFim,aGeren,lImpSint)
			dbSetOrder(2)
		Else
			//Se nao for for Top Connect
			#IFNDEF TOP 			
				CtSoEntid(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidFim,cMoeda,;
					cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,lNImpMov,cAlias,cIdent,;
					lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,cFilAte,lImpAntLP,;
					dDataLP,nDivide,lVlrZerado,lUsGaap,cMoedConv,cConsCrit,dDataConv,nTaxaConv,lRecDesp0,;
					cRecDesp,dDtZeraRD)
			#ELSE
				If TcSrvType() == "AS/400"  .Or. TcSrvType() <> 'AS/400' //.And. !u_CtbOracleV())
					CtSoEntid(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni,cEntidFim,cMoeda,;
						cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,lNImpMov,cAlias,cIdent,;
						lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,cFilDe,cFilAte,lImpAntLP,;
						dDataLP,nDivide,lVlrZerado,lUsGaap,cMoedConv,cConsCrit,dDataConv,nTaxaConv,lRecDesp0,;
						cRecDesp,dDtZeraRD)
				EndIf				
			#ENDIF			  
			     
			If lImpSint	//Se atualiza sinteticas			
				Do Case
				Case cAlias =="CT7"
					//Atualizacao de sinteticas para codebase e topconnect			        	
			 		CtContaSup(oMeter,oText,oDlg,lNImpMov,cMoeda)									 									
				Case cAlias == "CTU"			    		
					CtbCTUSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cIdent)
				EndCase
			EndIf

			dbSelectArea("cArqTmp")
			If FieldPos("ORDEMPRN") > 0
				dbSelectArea("cArqTmp")
				IndRegua("cArqTmp",Left(cArqInd, 7) + "A","ORDEMPRN",,,OemToAnsi(STR0001))  //"Selecionando Registros..."
				IndRegua("cArqTmp",Left(cArqInd, 7) + "B","SUPERIOR+CONTA",,,OemToAnsi(STR0001))  //"Selecionando Registros..."
				DbClearIndex()
				dbSetIndex(cArqInd+OrdBagExt())
				dbSetIndex(Left(cArqInd,7)+"A"+OrdBagExt())
				dbSetIndex(Left(cArqInd,7)+"B"+OrdBagExt())
				
				DbSetOrder(1)
				DbGoTop()
				While ! Eof()
					If Empty(SUPERIOR)
						CtGerSup(CONTA, @nOrdem)
					Endif
					DbSkip()
				Enddo
				DbSetOrder(2)
			Endif
		EndIf
	Else    	//Imprime Relatorios com 2 Entidades 
		If !Empty(aSetOfBook[5])
			MsgAlert(cMensagem,"")			
			Return
		Else
			If cAlias == 'CTY'		//Se for Relatorio de 2 Entidades filtrado pela 3a Entidade
				Ct2EntFil(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt)			
        	Else
				CtEntComp(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt)
			EndIf
		EndIf
	Endif
EndIf

RestArea(aSaveArea)

Return cArqTmp

Static Function lCtr510Det(oPrint,i,titulo,cProcesso,lLandScape)

Local aSetOfBook	:= CTBSetOf(mv_par02)
Local aCtbMoeda		:= {}
Local lin 			:= 2811
Local cArqTmp
//Local lRet 			:= .T.
//Local cSeparador	:= ""
Local cPicture
Local nPosCol
Local cDescMoeda
Local lFirstPage	:= .T.               
Local nTraco		:= 0
Local nSaldo
Local nTamLin		:= 2335
Local aPosCol		:= { 1800, 2075 }
Local cTpValor		:= GetMV("MV_TPVALOR")

aCtbMoeda := CtbMoeda(mv_par03, aSetOfBook[9])
If Empty(aCtbMoeda[1])                       
	Help(" ",1,"NOMOEDA")
    Return .F.
Endif

Titulo		:= If(! Empty(aSetOfBook[10]), aSetOfBook[10], Titulo)		// Titulo definido SetOfBook
cDescMoeda 	:= AllTrim(aCtbMoeda[3])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par03)

cPicture 	:= aSetOfBook[4]
If ! Empty(cPicture) .And. Len(Trans(0, cPicture)) > 17
	cPicture := ""
Endif

m_pag := mv_par07
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao					     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			lCTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			dFinalA+1,dFinal,"","", "",Repl("Z", Len(CT1->CT1_CONTA)),;
			"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
			"",Repl("Z", Len(CTH->CTH_CLVL)),mv_par03,;
			"1",aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30),,,,,;
			mv_par04 = 1, mv_par05)},STR0006, cProcesso) //"Criando Arquivo Temporario..."

dbSelectArea("cArqTmp")           
dbGoTop()

While ! Eof()

	If lin > 2810		
		If !lFirstPage
			oPrint:Line( ntraco,150,ntraco,nTamLin )   	// horizontal
		EndIf	
		i++                                                
		oPrint:EndPage() 	 								// Finaliza a pagina
		CtbCbcDem(oPrint,titulo,lLandScape)					// Funcao que monta o cabecalho padrao 
		If mv_par06 == 2									// Demonstra periodo anterior = Nao
			Ctr510Atu(oPrint, cDescMoeda,aPosCol,nTamLin)	// Cabecalho de impressão do Saldo atual.
		Else
			Ctr510Esp(oPrint, cDescMoeda,aPosCol,nTamLin)
		EndIf
		lin := 304        
		lFirstPage := .F.		
	End
    
	If DESCCTA = "-"
		oPrint:Line(lin,150,lin,nTamLin)   	// horizontal
	Else

		oPrint:Line( lin,150,lin+50, 150 )   	// vertical

// Negrito caso Sub-Total/Total/Separador (caso tenha descricao) e Igual (Totalizador)

		oPrint:Say(lin+15,195,DESCCTA, If(IDENTIFI $ "3469", oCouNew08N, oFont08))

		
		For nPosCol := 1 To Len(aPosCol)
			If mv_par06 == 2 .And. nPosCol == 1
				aPosCol := {2025}
			Else
				aPosCol	:= { 1800, 2025 }	           
			EndIf
			oPrint:Line(lin,aPosCol[nPosCol],lin+50,aPosCol[nPosCol])	// Separador vertical 
    	  
    		If IDENTIFI < "5"
    			If mv_par06 == 1 .Or. (mv_par06 == 2 .And. nPosCol == 1)
				    nSaldo := If(nPosCol = 1, SALDOATU, SALDOANT)
				       
		            ValorCTB(nSaldo,lin+15,aPosCol[nPosCol] + 5,15,nDecimais,.T.,cPicture,;
					NORMAL,CONTA,.T.,oPrint,cTpValor,IIf(IDENTIFI == "4","1",IDENTIFI))
				EndIf					 
			Endif 
			
		Next

		oPrint:Line(lin,nTamLin,lin+50,nTamLin)   	// Separador vertical
		lin +=47

	Endif

	nTraco := lin + 1
	DbSkip()
EndDo
oPrint:Line(lin,150,lin,nTamLin)   	// horizontal

lin += 10

DbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	
dbselectArea("CT2")

Return lin

static Function lCtbPlGeren(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,;
					cAlias,cIdent,lImpAntLP,dDataLP,lVlrZerado,cEntFil1,cEntFil2,aGeren,lImpSint)

Local aSaveArea := GetArea()
Local aSaldoAnt	
Local aSaldoAtu
Local aSaldoSEM
Local aSaldoPER

Local cConta
Local cCodNor
Local cNormal
Local cContaSup
Local cDesc
Local cPlanGer := aSetOfBook[5]
Local cZZZCT1	:= Repl("Z",Len(Criavar("CT1_CONTA")))
Local cZZZCTT	:= Repl("Z",Len(Criavar("CTT_CUSTO")))
Local cZZZCTD	:= Repl("Z",Len(Criavar("CTD_ITEM")))
Local cZZZCTH	:= Repl("Z",Len(Criavar("CTH_CLVL")))   
Local cContaIni	:= Space(Len(Criavar("CT1_CONTA")))
Local cContaFim	:= cZZZCT1
Local cCustoIni	:= Space(Len(Criavar("CTT_CUSTO")))
Local cCustoFim	:= cZZZCTT
Local cItemIni	:= Space(Len(Criavar("CTD_ITEM")))
Local cItemFim	:= cZZZCTD
Local cClvlIni	:= Space(Len(Criavar("CTH_CLVL")))
Local cClVlFim	:= cZZZCTH

Local cCtaFil1
Local cCtaFil2
Local cCCFil1
Local cCCFil2
Local cItemFil1
Local cItemFil2
Local cCLVLFil1
Local cCLVLFil2
Local lConta 	:= .F.
Local lCusto	:= .F.
Local lItem		:= .F.
Local lClasse	:= .F.

Local nReg
Local nFator	 := 1
Local nSaldoAnt := 0
Local nSaldoDeb := 0
Local nSaldoCrd := 0

Local nSaldoAtu := 0		// Saldo ate a data final
Local nSaldoSEM := 0		// Saldo ate a variavel dSemestre
Local nSaldoPER := 0		// Saldo ate a variavel dPeriodo0
Local nMOVIMPER	:= 0

Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nSaldoAtuC:= 0
Local lSemestre := FieldPos("SALDOSEM") > 0		// Saldo por semestre
Local lPeriodo0 := FieldPos("SALDOPER") > 0		// Saldo dois periodos anteriores

//Local aSalFormu

Local lComNivel := FieldPos("NIVEL") > 0		// Nivel hierarquico
Local lColuna	:= FieldPos("COLUNA") > 0
//Local aNiveis	:= {}
Local  nNivel, nContador
Local cFilCTS	:= xFilial("CTS")
Local nPos
//private 
lImpSint	:= .T.

lTRegCts	:= Type("lTRegCts") # "U" .And. ValType(lTRegCts) = "L" .And. lTRegCts
cAlias		:= Iif(cAlias == Nil,"",cAlias)
cIdent		:= Iif(cIdent == Nil,"",cIdent)
lVlrZerado	:= Iif(lVlrZerado == Nil,.T.,lVlrZerado)

If aGeren != Nil
	cCtaFil1  :=	aGeren[1]
	cCtaFil2  :=	aGeren[2]
	cCCFil1   :=	aGeren[3]
	cCCFil2   :=	aGeren[4]
	cItemFil1 :=	aGeren[5]
	cItemFil2 :=	aGeren[6]
	cCLVLFil1 :=	aGeren[7]
	cCLVLFil2 :=	aGeren[8]
EndIf	
lCT1Fil := .F.
lCTTFil := .F.
lCTDFil	:= .F.
lCTHFil	:= .F.

// Filtragem da entidade compositora do Plano Gerencial (Centro de Custo da Getdados)		
If !Empty(cCtaFil1) .Or. !Empty(cCtaFil2)
	lCT1Fil := .T.
	If cCtaFil1 > cContaIni 
		cContaIni := cCtaFil1
	EndIf
	If cCtaFil2 < cContaFim	
		cContaFim := cCtaFil2
	EndIf	
EndIf	

// Filtragem da entidade compositora do Plano Gerencial (Centro de Custo da Getdados)		
If !Empty(cCCFil1) .Or. !Empty(cCCFil2)
	lCTTFil := .T.
	If cCCFil1 > cCustoIni 
		cCustoIni := cCCFil1
	EndIf
	If cCCFil2 < cCustoFim	
		cCustoFim := cCcFil2
	EndIf	
EndIf	
/* Observacoes:
C.Custo do Plano Gerencial
001	002	003
			
C.Custo Informado no Filtro
000	001	002	003	004
			
O relatorio so podera imprimir: 001 002 003	*/

// Filtragem da entidade compositora do Plano Gerencial (Item Contabil da Getdados)
If !Empty(cItemFil1) .Or. !Empty(cItemFil2)
	lCTDFil := .T.
	If cItemFil1 > cItemIni 
		cItemIni := cItemFil1
	EndIf
	If cItemFil2 < cItemFim	
		cItemFim := cItemFil2
	EndIf	
EndIf	

// Filtragem da entidade compositora do Plano Gerencial (Classe de Valor da Getdados)
If !Empty(cCLVLFil1) .Or. !Empty(cCLVLFil2)
	lCTHFil := .T.
	If cCLVLFil1 > cClVlIni 
		cClVlIni := cClVlFil1
	EndIf
	If cCLVLFil2 < cClVlFim	
		cClVlFim := cClVlFil2
	EndIf	
EndIf	

dbSelectArea("CTS")
oMeter:nTotal := CTS->(RecCount())
dbSetOrder(1)

MsSeek(cFilCTS+cPlanGer,.T.)

While !Eof() .And. 	CTS->CTS_FILIAL == cFilCTS .And.;
					CTS->CTS_CODPLA == cPlanGer

	If CTS->CTS_CLASSE == "1"// .And. (! CTS->CTS_IDENT $ "3456")
		dbSkip()
		Loop
	EndIf

	//Efetua o filtro dos parametros considerando o plano gerencial.
	If !Empty(cEntFil1) .Or. !Empty(cEntFil2)
		If CTS->CTS_CONTAG < cEntFil1 .Or. CTS->CTS_CONTAG > cEntFil2
			dbSkip()
			Loop
		EndIf	
	EndIf	                                   
	// Recarrega variáveis
	lConta 	:= .F.
	lCusto	:= .F.
	lItem	:= .F.
	lClasse	:= .F.

	// Grava conta analitica
	cConta 	:= CTS->CTS_CONTAG
	cDesc	:= CTS->CTS_DESCCG
	cOrdem	:= CTS->CTS_ORDEM

	nSaldoAnt 	:= 0	// Zero as variaveis para acumular
	nSaldoDeb 	:= 0
	nSaldoCrd 	:= 0

	nSaldoAtu 	:= 0
	nSaldoSEM 	:= 0
	nSaldoPer	:= 0

	nSaldoAntD	:= 0
	nSaldoAntC	:= 0
	nSaldoAtuD	:= 0
	nSaldoAtuC	:= 0
	nMOVIMPER	:= 0
	dbSelectArea("CTS")
	dbSetOrder(1)

	While !Eof() .And. CTS->CTS_FILIAL == cFilCTS .And.;
						CTS->CTS_CODPLA == cPlanGer  .And. CTS->CTS_ORDEM	== cOrdem
		aSaldoAnt	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		aSaldoAtu	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		aSaldoSEM	:= { 0, 0, 0, 0, 0, 0, 0, 0 }
		aSaldoPER	:= { 0, 0, 0, 0, 0, 0, 0, 0 }

		lClasse := .F.
		lItem	:= .F.
		lCusto	:= .F.
		lConta	:= .F.

		If !lCTHFil
			If !Empty(CTS->CTS_CTHINI) .Or. !Empty(CTS->CTS_CTHFIM)		// Saldo a partir da classe
				cClVlIni	:= CTS->CTS_CTHINI
				cClVlFim	:= CTS->CTS_CTHFIM
				lClasse := .T.
			Else
				cCLVLIni	:= ""
				cCLVLFim	:= cZZZCTH
			EndIf
		Endif

		If !lCTDFil
			If !Empty(CTS->CTS_CTDINI) .Or. !Empty(CTS->CTS_CTDFIM)	// Saldo a partir do Item
				cItemIni	:= CTS->CTS_CTDINI
				cItemFim	:= CTS->CTS_CTDFIM			
				lItem := .T.
			Else
				cItemIni	:= ""
				cItemFim	:= cZZZCTD        		
			EndIf
		Endif
		
		If !lCTTFil
			If !Empty(CTS->CTS_CTTINI) .Or. !Empty(CTS->CTS_CTTFIM)	// Saldo a partir do C.Custo
				cCustoIni	:= CTS->CTS_CTTINI
				cCustoFim	:= CTS->CTS_CTTFIM
				lCusto := .T.
			Else
				cCustoIni	:= ""
				cCustoFim	:= cZZZCTT        
			EndIf
		Endif

		If !lCT1Fil
			If !Empty(CTS->CTS_CT1INI) .Or. !Empty(CTS->CTS_CT1FIM)	// Saldo a partir da Conta
				cContaIni	:= CTS->CTS_CT1INI
				cContaFim	:= CTS->CTS_CT1FIM
				lConta := .T.
			Else
				cContaIni	:= ""
				cContaFim	:= cZZZCT1
			EndIf
		EndIf
		If lClasse
			aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
									cItemFim,cCustoIni,cCustoFim,cContaIni,;
									cContaFim,dDataIni,cMoeda,CTS->CTS_TPSALD)
								
			aSaldoAtu := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
									cItemFim,cCustoIni,cCustoFim,cContaIni,;
									cContaFim,dDataFim,cMoeda,CTS->CTS_TPSALD)
			If lSemestre
				aSaldoSem := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
										cItemFim,cCustoIni,cCustoFim,cContaIni,;
										cContaFim,dSemestre,cMoeda,CTS->CTS_TPSALD)
			Endif
			If lPeriodo0
				aSaldoPer := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,;
										cItemFim,cCustoIni,cCustoFim,cContaIni,;
										cContaFim,dPeriodo0,cMoeda,CTS->CTS_TPSALD)
			Endif
		ElseIf lItem		
			aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
									cCustoFim,cContaIni,cContaFim,;
									dDataIni,cMoeda,CTS->CTS_TPSALD)
								
			aSaldoAtu := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
									cCustoFim,cContaIni,cContaFim,;
									dDataFim,cMoeda,CTS->CTS_TPSALD)
			If lSemestre
				aSaldoSem := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
										cCustoFim,cContaIni,cContaFim,;
										dSemestre,cMoeda,CTS->CTS_TPSALD)
			Endif
			If lPeriodo0
				aSaldoPEr := SaldTotCT4(cItemIni,cItemFim,cCustoIni,;
										cCustoFim,cContaIni,cContaFim,;
										dPeriodo0,cMoeda,CTS->CTS_TPSALD)
			Endif
		ElseIf lCusto
			aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
									cContaFim,dDataIni,cMoeda,CTS->CTS_TPSALD)
			aSaldoAtu := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
									cContaFim,dDataFim,cMoeda,CTS->CTS_TPSALD)
			If lSemestre
				aSaldoSem := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
										cContaFim,dSemestre,cMoeda,CTS->CTS_TPSALD)
			Endif
			If lPeriodo0
				aSaldoPer := SaldTotCT3(cCustoIni,cCustoFim,cContaIni,;
										cContaFim,dPeriodo0,cMoeda,CTS->CTS_TPSALD)
			Endif
		ElseIf lConta
			aSaldoAnt := SaldTotCT7(cContaIni,cContaFim,dDataIni,cMoeda,CTS->CTS_TPSALD,lImpAntLP,dDataLP)
			aSaldoAtu := SaldTotCT7(cContaIni,cContaFim,dDataFim,cMoeda,CTS->CTS_TPSALD,lImpAntLP,dDataLP)
			If lSemestre
				aSaldoSem := SaldTotCT7(cContaIni,cContaFim,dSemestre,cMoeda,CTS->CTS_TPSALD,lImpAntLP,dDataLP)
			Endif
			If lPeriodo0
				aSaldoPer := SaldTotCT7(cContaIni,cContaFim,dPeriodo0,cMoeda,CTS->CTS_TPSALD,lImpAntLP,dDataLP)
			Endif
		EndIf		

		If aSetOfBook[9] > 1	// Divisao por fator
			nLSldAnt := Len(aSaldoAnt)
			nLSldAtu := Len(aSaldoAtu)
			nLSldSem := Len(aSaldoSem)
			nLSldPer := Len(aSaldoPer)
			For nPos := 1 To nLSldAnt
				aSaldoAnt[nPos] := Round(NoRound((aSaldoAnt[nPos]/aSetOfBook[9]),3),2)
			Next
			For nPos := 1 To nLSldAtu
				aSaldoAtu[nPos] := Round(NoRound((aSaldoAtu[nPos]/aSetOfBook[9]),3),2)
			Next
			If lSemestre
				For nPos := 1 To nLSldSem
					aSaldoSem[nPos] := Round(NoRound((aSaldoSem[nPos]/aSetOfBook[9]),3),2)
				Next
			Endif
			If lPeriodo0
				For nPos := 1 To nLSldPer
					aSaldoPer[nPos] := Round(NoRound((aSaldoPer[nPos]/aSetOfBook[9]),3),2)
				Next
			Endif
		Endif

		If Left(CTS->CTS_FORMUL, 7) == "ROTINA="
			nLSldAnt := Len(aSaldoAnt)
			nLSldAtu := Len(aSaldoAtu)
			nLSldSem := Len(aSaldoSem)
			nLSldPer := Len(aSaldoPer)
			nFator := &(Subs(CTS->CTS_FORMUL, 8))
			For nPos := 1 To nLSldAnt
				aSaldoAnt[nPos] := nFator
			Next
			For nPos := 1 To nLSldAtu
				aSaldoAtu[nPos] := nFator
			Next
			If lSemestre
				For nPos := 1 To nLSldSem
					aSaldoSem[nPos] := nFator
				Next
			Endif
			If lPeriodo0
				For nPos := 1 To nLSldPer
					aSaldoPer[nPos] := nFator
				Next
			Endif
		Endif
			
		// Calculos com os Fatores
		If CTS->CTS_IDENT = "1"				// Somo os saldos
			nSaldoAnt 	+= aSaldoAnt[6]		// Saldo Anterior
			nSaldoAtu 	+= aSaldoAtu[1]		// Saldo Atual
			If lSemestre
				nSaldoSem += aSaldoSEM[1]	// Saldo Semestre
			Endif
			If lPeriodo0
				nSaldoPer += aSaldoPER[1]	// Saldo variavel dPeriodo0
			Endif
				
			nSaldoAntD 	+= aSaldoAnt[7]
			nSaldoAntC 	+= aSaldoAnt[8]

			nSaldoAtuD 	+= aSaldoAtu[4]
			nSaldoAtuC 	+= aSaldoAtu[5] 
		
			nSaldoDeb  	:= (nSaldoAtuD - nSaldoAntD)
			nSaldoCrd  	:= (nSaldoAtuC - nSaldoAntC)
				
		ElseIf CTS->CTS_IDENT = "2"			// Subtraio os saldos
			nSaldoAnt 	-= aSaldoAnt[6]		// Saldo Anterior
			nSaldoAtu 	-= aSaldoAtu[1]		// Saldo Atual
			If lSemestre
				nSaldoSem -= aSaldoSEM[1]	// Saldo Semestre
			Endif
			If lPeriodo0
				nSaldoPer -= aSaldoPER[1]	// Saldo Periodo determinado
			Endif
				
			nSaldoAntD 	-= aSaldoAnt[7]
			nSaldoAntC 	-= aSaldoAnt[8]
		
			nSaldoAtuD 	-= aSaldoAtu[4]
			nSaldoAtuC 	-= aSaldoAtu[5] 
		
			nSaldoDeb  	:= (nSaldoAtuD - nSaldoAntD)
			nSaldoCrd  	:= (nSaldoAtuC - nSaldoAntC)
		
		EndIf
       
		nMOVIMPER += (aSaldoAnt[5] - aSaldoPer[8]) - (aSaldoAnt[4] - aSaldoPer[7])

		dbSelectArea("CTS")
		dbSetOrder(1)  
		nReg := Recno()
		dbSkip()
		
		If lTRegCts .And. CTS_COLUNA > 0	// A coluna 0 nao respeita desmembramento
			Exit
		Endif		
	EnddO

	dbSelectArea("CTS")
	dbSetOrder(2)
	dbGoTo(nReg)
	cCodNor := CTS->CTS_NORMAL

	If !lVlrZerado .And. (nSaldoCrd-nSaldoDeb = 0 .And. nSaldoAnt == 0 .And. nSaldoAtu == 0) .And. ;
		(nSaldoDeb = 0 .And. nSaldoCRD = 0) 
		///DbDelete()			/// RETIRADO DELETE 
		
		dbSelectArea("CTS")	
		dbSetOrder(1)
		dbGoTo(nReg)
		dbSkip()
   		Loop					/// SÓ INCLUI NO TMP SE O SALDO NÃO ESTIVER ZERADO (NAO PRECISA ATUALIZAR SUPERIORES)
    EndIf	
	    
	dbSelectArea("cArqTmp")
	dbSetOrder(1)	
	If !MsSeek(cConta)
		dbAppend()                    
		If cAlias = 'CTU'
			Do Case
			Case cIdent	= 'CTT'
				Replace CUSTO 	With  cConta
				Replace DESCCC	With cDesc						
				Replace TIPOCC 	With CTS->CTS_CLASSE				
			Case cIdent = 'CTD'
				Replace ITEM 		With cConta
				Replace DESCITEM    With cDesc			
				Replace TIPOITEM	With CTS->CTS_CLASSE
			Case cIdent = 'CTH'
				Replace CLVL		With cConta
				Replace DESCCLVL	With cDesc			
				Replace TIPOCLVL	With CTS->CTS_CLASSE							
			EndCase                          
		Else
			Replace CONTA 		With cConta
			Replace DESCCTA    	With cDesc
		EndIf
		Replace SUPERIOR  	With CTS->CTS_CTASUP
		Replace TIPOCONTA 	With CTS->CTS_CLASSE
		Replace NORMAL    	With CTS->CTS_NORMAL
		Replace ORDEM		With CTS->CTS_ORDEM
		Replace IDENTIFI	With CTS->CTS_IDENT
		If lColuna
			Replace COLUNA  With CTS->CTS_COLUNA
		Endif

		If lTRegCts
			CT1->(DbSeek(xFilial("CT1") + CTS->CTS_CT1INI))
			Replace DESCORIG 	With &("CT1->CT1_DESC" + cMoeda),;
					TIPOCONTA 	With CT1->CT1_CLASSE,;
					NORMAL    	With CT1->CT1_NORMAL
		Endif		
	EndIf

	If Left(CTS->CTS_FORMUL, 6) = "TEXTO="		// Adiciona texto a descricao
		Replace ("cArqTmp")->DESCCTA With 	AllTrim(("cArqTmp")->DESCCTA) + Space(1) +;
												&(Subs(CTS->CTS_FORMUL, 7))
	Endif

	dbSelectArea("cArqTmp")
	Replace	SALDOANT With nSaldoAnt			// Saldo Anterior
	Replace SALDOATU With nSaldoAtu			// Saldo Atual

	Replace SALDOATUDB With nSaldoAtuD		//Saldo Atual Devedor
	Replace SALDOATUCR With nSaldoAtuC		//Saldo Atual Credor
	
	If lSemestre
		Replace SALDOSEM With nSaldoSEM		// Saldo Semestre
	Endif
	
	If lPeriodo0	// Saldo periodo determinado
		Replace SALDOPER 	With nSaldoPER
		Replace MOVIMPER  	With nMOVIMPER 
	Endif

	If nSaldoDeb < 0 //.And. cCodNor == "1"
		Replace SALDOCRD	With nSaldoDeb
	ElseIf nSaldoDeb >= 0 //.And. cCodNor == "1"
		Replace SALDODEB	With nSaldoDeb
	EndIf
	If nSaldoCrd < 0// .And. cCodNor == "2"
		Replace SALDODEB	With nSaldoCrd
	ElseIf nSaldoCrd >= 0 //.And. cCodNor == "2"
		Replace SALDOCRD	With nSaldoCrd
	EndIf
	
	Replace MOVIMENTO With nSaldoCrd-nSaldoDeb
    	
	If lComNivel
		aNivel := {}
		Aadd(aNivel, Recno())
	Endif
 
	If lImpSint
		dbSelectArea("CTS")
		dbSetOrder(2)
		// Grava contas sinteticas
		If !Empty(CTS->CTS_CTASUP)
			While !Eof() .And. 	CTS->CTS_FILIAL == cFilCTS .And. ;
									CTS->CTS_CODPLAN == cPlanGer
		
				cContaSup 	:= CTS->CTS_CTASUP
				
				dbSelectArea("CTS")
				dbSetOrder(2)
				If MsSeek(cFilCTS+cPlanGer+cContaSup)
					cDesc 	:= CTS->CTS_DESCCG
					cNormal := CTS->CTS_NORMAL
				Else
					cNormal	:= cCodNor	
				EndIf
   	
				dbSelectArea("cArqTmp")
				dbSetOrder(1)
				If !MsSeek(cContaSup)
					dbAppend() 
					If cAlias = 'CTU'	                     
						Do Case
						Case cIdent = 'CTT'
							Replace CUSTO 		With cContaSup			
							Replace DESCCC		With cDesc								
							Replace TIPOCC		With CTS->CTS_CLASSE
						Case cIdent	= 'CTD'
							Replace ITEM 		With cContaSup
							Replace DESCITEM	With cDesc          
							Replace TIPOITEM	With CTS->CTS_CLASSE
						Case cIdent = 'CTH'
							Replace CLVL 		With cContaSup
							Replace DESCCLVL	With cDesc          
						Replace TIPOCLVL	With CTS->CTS_CLASSE
						EndCase
					Else	
						Replace CONTA	With cContaSup
						Replace DESCCTA With cDesc		
					EndIf
					Replace SUPERIOR  	With CTS->CTS_CTASUP
					Replace TIPOCONTA	With CTS->CTS_CLASSE
					Replace NORMAL   	With CTS->CTS_NORMAL
					Replace ORDEM		With CTS->CTS_ORDEM
					Replace IDENTIFI	With CTS->CTS_IDENT
					If lColuna
						Replace COLUNA  With CTS->CTS_COLUNA
					Endif
					If lTRegCts
						CT1->(DbSeek(xFilial("CT1") + CTS->CTS_CT1INI))
						Replace DESCORIG 	With &("CT1->CT1_DESC" + cMoeda),;
								TIPOCONTA 	With CT1->CT1_CLASSE,;
								NORMAL    	With CT1->CT1_NORMAL
					Endif
				EndIf    
		
				Replace	SALDOANT With SALDOANT + nSaldoAnt			// Saldo Anterior
				Replace SALDOATU With SALDOATU + nSaldoAtu			// Saldo Atual
				
				Replace SALDOATUDB With SALDOATUDB + nSaldoAtuD		//Saldo Atual Devedor
				Replace SALDOATUCR With SALDOATUCR + nSaldoAtuC		//Saldo Atual Credor
				
				If nSaldoDeb < 0 //.And. cNormal == "1"
					Replace SALDOCRD	With SALDOCRD + nSaldoDeb
				ElseIf nSaldoDeb >= 0 //.And. cNormal == "1"
					Replace SALDODEB	With SALDODEB + nSaldoDeb
				EndIf
				If nSaldoCrd < 0 //.And. cNormal == "2"
					Replace SALDODEB	With SALDODEB + nSaldoCrd
				ElseIf nSaldoCrd >= 0 //.And. cNormal == "2"
					Replace SALDOCRD	With SALDOCRD + nSaldoCrd
				EndIf
   	
//				Replace MOVIMENTO With nSaldoCrd-nSaldoDeb
				Replace MOVIMENTO With SALDOCRD-SALDODEB
				
				If lSemestre		// Saldo por semestre
					Replace SALDOSEM With SALDOSEM + nSaldoSEM
				Endif
				If lPeriodo0		// Saldo periodo determinado
					Replace SALDOPER With SALDOPER + nSaldoPER
				Endif
   	
  	            If lComNivel
					Aadd(aNivel, Recno())
				Endif
				
				dbSelectArea("CTS")
				If !Eof() .And. Empty(CTS->CTS_CTASUP)
					dbSelectArea("cArqTmp")
					Replace NIVEL1 With .T.
					dbSelectArea("CTS")
					Exit
				EndIf
			EndDo
		
			If lComNivel
				dbSelectArea("cArqTmp")
				nContador 	:= 1
				For nNivel 	:= Len(aNivel) To 1 Step -1
					DbGoto(aNivel[nNivel])
					Replace NIVEL With nContador ++
				Next		
			Endif
		
		EndIf
	Endif
	
	dbSelectArea("CTS")
	dbSetOrder(1)
	dbGoTo(nReg)
	dbSkip()

EndDo

RestArea(aSaveArea)

Return
