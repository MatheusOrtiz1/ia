#INCLUDE "TOTVS.CH"
#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"
//Constantes
#Define STR_PULA    Chr(13)+Chr(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  RELVIDASC   º Autor ³ EVERTON FORTI     º Data ³  31/01/23   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ EXPORTA VIDA SOLICITAÇÃO DE COMPRAS                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function RELVIDASC()

IF INPUT()
	PROCESSA({|| RELSC1()})
ENDIF

Return()

Static Function RELSC1()
Local i
Local _planilha   :=  "SC1XSC7"
Local _tab          :=  "Filial "+ALLTRIM(SM0->M0_FILIAL)
Local cSc7NUM     :=  ""
Local cSc7ITEM     :=  ""
Local cSc7EMIS    :=  ""
Local cSc7COND    :=  ""
Local cSc7DTLIB   :=  ""
Local cSc7FORN    :=  ""
Local cSc7LOJA    :=  ""
Local cSc7QTDD    :=  ""
Local cSc7QUJE    :=  ""
Local cSc7QUJE2   :=  ""
Local cSc7TOTAL   :=  ""
Local cSc7COMPR   :=  ""
Local cDbmulIB1   :=  ""
Local cDbmNiv01   :=  ""
Local dDbmDtL01   :=  ""
Local cDbmulIB2   :=  ""
Local cDbmNiv02   :=  ""
Local dDbmDtL02   :=  ""
Local cDbmulIB3   :=  ""
Local cDbmNiv03   :=  ""
Local dDbmDtL03   :=  ""
Local cCRApro      := ""
local cCRNivl      := ""
local cCRStat      := ""
local cCRDtLib     := ""
local cCRusrLib    := ""
lOCAL  cQuery     :=  ""                     
lOCAL  cQuery2    :=  ""                     
lOCAL  cQuery3    :=  ""                     
Private aDados := {}                      
Private aScr := {}                      
Private aTemp := {}                      

cQuery := " "
cQuery += " SELECT * "
cQuery += " FROM "+RetSqlName("SC1")+" SC1 "
cQuery += " WHERE SC1.D_E_L_E_T_=' '  "
cQuery += " AND C1_FILIAL='"+xFilial("SC1")+"'  " 
cQuery += " AND C1_NUM >='"+MV_PAR01+"' "
cQuery += " AND C1_NUM <='"+MV_PAR02+"' "
cQuery += " AND C1_EMISSAO >='"+DTOS(MV_PAR03)+"' "
cQuery += " AND C1_EMISSAO <='"+DTOS(MV_PAR04)+"' "
cQuery += " ORDER BY C1_NUM,C1_ITEM "
conout(cQuery)
IF SELECT("TMPSC1")!=0
    TMPSC1->(DBCLOSEAREA())
ENDIF
 TCQUERY cQuery NEW ALIAS "TMPSC1"
dbselectarea("TMPSC1")
if TMPSC1->(!eof())
 
	while TMPSC1->(!eof())

        cSc7NUM     :=  ""
        cSc7ITEM     :=  ""
        cSc7EMIS    :=  ""
        cSc7COND    :=  ""
        cSc7DTLIB   :=  ""
        cSc7FORN    :=  ""
        cSc7LOJA    :=  ""
        cSc7QTDD    :=  ""
        cSc7QUJE    :=  ""
        cSc7QUJE2   :=  ""
        cSc7TOTAL   :=  ""
        cSc7COMPR   :=  ""
        cCRApro     := ""
        cCRNivl     := ""
        cCRStat     := ""
        cCRDtLib    := ""
        cCRusrLib   := ""
        cDbmulISC   := ""
        cDbmNivSC   := ""
        dDbmDtLSC    := ""
        cDbmulIB1   := ""
        cDbmNiv01   := ""
        dDbmDtL01    := ""
        cDbmulIB2   := ""
        cDbmNiv02   := ""
        dDbmDtL02   := ""
        cDbmulIB3    := ""
        cDbmNiv03   := ""
        dDbmDtL03   := ""
         
        cQuery3 := " SELECT TOP 03 "
        cQuery3 += " SCR.*,DBM.DBM_ITEM,DBM.DBM_APROV,DBM.DBM_ITEMRA,SCR.R_E_C_N_O_ SCRRECNO "
        cQuery3 += " FROM "+RetSqlName("SCR")+" SCR "
        cQuery3 += " LEFT JOIN "+RetSqlName("DBM")+" DBM "
        cQuery3 += " ON DBM.DBM_FILIAL='"+xFilial("SCR")+"' AND SCR.CR_TIPO=DBM.DBM_TIPO AND SCR.CR_NUM=DBM.DBM_NUM AND SCR.CR_GRUPO=DBM.DBM_GRUPO    "
        cQuery3 += " AND SCR.CR_ITGRP=DBM.DBM_ITGRP AND SCR.CR_USER=DBM.DBM_USER AND SCR.CR_USERORI=DBM.DBM_USEROR   "
        cQuery3 += " AND SCR.CR_APROV=DBM.DBM_USAPRO AND SCR.CR_APRORI=DBM.DBM_USAPOR AND SCR.D_E_L_E_T_ = DBM.D_E_L_E_T_ AND DBM.D_E_L_E_T_ = ' '   "
        cQuery3 += " WHERE  SCR.CR_FILIAL='"+xFilial("SCR")+"' AND SCR.CR_NUM = '"+TMPSC1->C1_NUM+"' AND DBM_ITEM='"+TMPSC1->C1_ITEM+"'  " 
        cQuery3 += " AND SCR.CR_TIPO IN('SC') AND SCR.D_E_L_E_T_=' '   ORDER BY  CR_FILIAL,CR_TIPO,CR_NUM,CR_NIVEL " 
        conout(cQuery3)
        IF SELECT("TMPDBMSC")!=0
        TMPDBMSC->(DBCLOSEAREA())
        ENDIF
        TCQUERY cQuery3 NEW ALIAS "TMPDBMSC"	    
        dbselectarea("TMPDBMSC")

        if TMPDBMSC->(!eof())
            while TMPDBMSC->(!eof()) 
                //
                IF (TMPDBMSC->CR_NIVEL == '01' .OR. TMPDBMSC->CR_NIVEL == '1') .AND. !EMPTY(TMPDBMSC->CR_DATALIB) .AND. TMPDBMSC->CR_TIPO  == 'SC' 
                    cDbmulISC   := UsrFullName(TMPDBMSC->CR_USERLIB)
                    cDbmNivSC   := TMPDBMSC->CR_NIVEL
                    dDbmDtLSC   := STOD(TMPDBMSC->CR_DATALIB)
                ENDIF
            TMPDBMSC->(DBSKIP())
            ENDDO
        ENDIF

        IF !EMPTY(TMPSC1->C1_PEDIDO)    
            cQuery2 := " "
            cQuery2 += " SELECT * "
            cQuery2 += " FROM "+RetSqlName("SC7")+" SC7 "
            cQuery2 += " WHERE SC7.D_E_L_E_T_=' '  "
            cQuery2 += " AND C7_FILIAL='"+xFilial("SC7")+"'  " 
            cQuery2 += " AND C7_NUMSC ='"+TMPSC1->C1_PEDIDO+"' "
            cQuery2 += " AND C7_ITEMSC ='"+TMPSC1->C1_ITEMPED+"' "
            cQuery2 += " AND C7_EMISSAO >='"+DTOS(MV_PAR05)+"' "
            cQuery2 += " AND C7_EMISSAO <='"+DTOS(MV_PAR06)+"' "
            cQuery2 += " ORDER BY C7_NUM,C7_ITEM "
            conout(cQuery2)
            IF SELECT("TMPSC7")!=0
                TMPSC7->(DBCLOSEAREA())
            ENDIF
            TCQUERY cQuery2 NEW ALIAS "TMPSC7"	    
            dbselectarea("TMPSC7")
            if TMPSC7->(!eof())
            
                while TMPSC7->(!eof()) .AND. !EMPTY(TMPSC7->C7_NUM)
                       
                        cSc7NUM     :=  TMPSC7->C7_NUM
                        cSc7ITEM    :=  TMPSC7->C7_ITEM
                        cSc7EMIS    :=  TMPSC7->C7_EMISSAO
                        cSc7COND    :=  TMPSC7->C7_COND
                        cSc7DTLIB   :=  TMPSC7->C7_DATALIB
                        cSc7FORN    :=  TMPSC7->C7_FORNECE
                        cSc7LOJA    :=  TMPSC7->C7_LOJA
                        cSc7QTDD    :=  TMPSC7->C7_QUANT
                        cSc7QUJE    :=  TMPSC7->C7_QUJE
                        cSc7TOTAL   :=  TMPSC7->C7_TOTAL
                        cSc7COMPR   :=  POSICIONE("SY1",1,xFilial("SY1")+TMPSC7->C7_COMPRA,"Y1_NOME")
                    
                        cQuery3 := " SELECT TOP 03 "
                        cQuery3 += " SCR.*,DBM.DBM_ITEM,DBM.DBM_APROV,DBM.DBM_ITEMRA,SCR.R_E_C_N_O_ SCRRECNO "
                        cQuery3 += " FROM "+RetSqlName("SCR")+" SCR "
                        cQuery3 += " LEFT JOIN "+RetSqlName("DBM")+" DBM "
                        cQuery3 += " ON DBM.DBM_FILIAL='"+xFilial("SCR")+"' AND SCR.CR_TIPO=DBM.DBM_TIPO AND SCR.CR_NUM=DBM.DBM_NUM AND SCR.CR_GRUPO=DBM.DBM_GRUPO    "
                        cQuery3 += " AND SCR.CR_ITGRP=DBM.DBM_ITGRP AND SCR.CR_USER=DBM.DBM_USER AND SCR.CR_USERORI=DBM.DBM_USEROR   "
                        cQuery3 += " AND SCR.CR_APROV=DBM.DBM_USAPRO AND SCR.CR_APRORI=DBM.DBM_USAPOR AND SCR.D_E_L_E_T_ = DBM.D_E_L_E_T_ AND DBM.D_E_L_E_T_ = ' '   "
                        cQuery3 += " WHERE  SCR.CR_FILIAL='"+xFilial("SCR")+"' AND SCR.CR_NUM = '"+cSc7NUM+"' AND DBM_ITEM='"+cSc7ITEM+"'  " 
                        cQuery3 += " AND SCR.CR_TIPO IN('IP','PC') AND SCR.D_E_L_E_T_=' '  AND CR_USERLIB <> '' ORDER BY  CR_FILIAL,CR_TIPO,CR_NUM,CR_NIVEL " 
                        conout(cQuery3)
                        IF SELECT("TMPDBM")!=0
                        TMPDBM->(DBCLOSEAREA())
                        ENDIF
                        TCQUERY cQuery3 NEW ALIAS "TMPDBM"	    
                        dbselectarea("TMPDBM")

                        if TMPDBM->(!eof())
                            while TMPDBM->(!eof()) 
                                //DBM PEDIDO DE COMPRA
                                IF !EMPTY(TMPDBM->CR_DATALIB) .AND. EMPTY(cDbmulIB1)
                                    cDbmulIB1   := UsrFullName(TMPDBM->CR_USERLIB)
                                    cDbmNiv01   := TMPDBM->CR_NIVEL
                                    dDbmDtL01   := STOD(TMPDBM->CR_DATALIB)
                                ENDIF
                                IF !EMPTY(TMPDBM->CR_DATALIB)  .AND. EMPTY(cDbmulIB2)
                                    cDbmulIB2    := UsrFullName(TMPDBM->CR_USERLIB)
                                    cDbmNiv02   := TMPDBM->CR_NIVEL
                                    dDbmDtL02   := STOD(TMPDBM->CR_DATALIB)
                                ENDIF
                                IF !EMPTY(TMPDBM->CR_DATALIB)  .AND. EMPTY(cDbmulIB3)
                                    cDbmulIB3   := UsrFullName(TMPDBM->CR_USERLIB)
                                    cDbmNiv03   := TMPDBM->CR_NIVEL
                                    dDbmDtL03   := STOD(TMPDBM->CR_DATALIB)
                                ENDIF
                        TMPDBM->(DBSKIP()) 
                        ENDDO
                        ENDIF                    
                //29
                TMPSC7->(DBSKIP())
                ENDDO
            ENDIF
        ENDIF
        aTemp       := {}     
        aadd(aTemp,TMPSC1->C1_CLVL )        //1
        aadd(aTemp,POSICIONE('CTH',1,XFILIAL('CTH')+TMPSC1->C1_CLVL,"CTH_DESC01")    )        //1
        aadd(aTemp,TMPSC1->C1_NUM )         //2
        aadd(aTemp,TMPSC1->C1_ITEM )        //3
        aadd(aTemp,TMPSC1->C1_PRODUTO )     //4
        aadd(aTemp,TMPSC1->C1_UM )          //5
        aadd(aTemp,TMPSC1->C1_DESCRI )      //6
        aadd(aTemp,TMPSC1->C1_QUANT)        //7
        aadd(aTemp,DTOC(STOD(TMPSC1->C1_EMISSAO)))//8
        aadd(aTemp,DTOC(STOD(TMPSC1->C1_DATPRF)))//9
        aadd(aTemp,TMPSC1->C1_APROV )       //11
        aadd(aTemp,TMPSC1->C1_QUJE )        //12
        aadd(aTemp,TMPSC1->C1_CO )          //14
        aadd(aTemp,POSICIONE('AK5',1,XFILIAL('AK5')+TMPSC1->C1_CO,"AK5_DESCRI") )          //14
        aadd(aTemp,TMPSC1->C1_CC )   
        aadd(aTemp,POSICIONE('CTT',1,XFILIAL('CTT')+TMPSC1->C1_CC,"CTT_DESC01") )          //15       //15
        aadd(aTemp,TMPSC1->C1_ITEMCTA )     //16
        aadd(aTemp,POSICIONE('CTH',1,XFILIAL('CTH')+TMPSC1->C1_ITEMCTA,"CTH_DESC01") )     //16
        aadd(aTemp,TMPSC1->C1_CLVL )        //17
        aadd(aTemp,TMPSC1->C1_OBS	)       //18
        aadd(aTemp,cSc7NUM	)               //19
        aadd(aTemp,cSc7ITEM	)               //19
        aadd(aTemp,cSc7EMIS	)               //20
        aadd(aTemp,cSc7COND	)               //21
        aadd(aTemp,cSc7DTLIB)               //22
        aadd(aTemp,cSc7FORN	)               //23
        aadd(aTemp,cSc7LOJA	)               //24
        aadd(aTemp,cSc7QTDD	)               //25
        aadd(aTemp,cSc7QUJE	)               //26
        aadd(aTemp,transform(cSc7TOTAL,'@E 99,999,999,999.99'))               //28
        aadd(aTemp,cSc7COMPR)  
        aadd(aTemp,cDbmulISC)  
        aadd(aTemp,cDbmNivSC)  
        aadd(aTemp,dDbmDtLSC)  
        aadd(aTemp,cDbmulIB1)  
        aadd(aTemp,cDbmNiv01)  
        aadd(aTemp,dDbmDtL01)  
        aadd(aTemp,cDbmulIB2)  
        aadd(aTemp,cDbmNiv02)  
        aadd(aTemp,dDbmDtl02)  
        aadd(aTemp,cDbmulIB3)  
        aadd(aTemp,cDbmNiv03)  
        aadd(aTemp,dDbmDtL03)  
        
        if len(aTemp) >0 
            aadd(aDados,aClone(aTemp))
        ENDIF

		TMPSC1->(dbskip())
	enddo
endif

IF LEN(aDados) <=0
    MsgInfo("DADOS NÃO ENCONTRADO!","REVISAR PARAMETROS")
    RETURN()
ENDIF

TMPSC1->(dbclosearea())
TMPSC7->(dbclosearea())
if len(aDados)>0
	oExcel := FWMSEXCEL():New()
	oExcel:AddworkSheet(_planilha)
	oExcel:AddTable(_planilha,_tab)
	oExcel:AddColumn(_planilha,_tab,"Unidade Requisitante",1,1)     //1
	oExcel:AddColumn(_planilha,_tab,"Descr.Unid.Requisitante",1,1)  //1
	oExcel:AddColumn(_planilha,_tab,"Numero SC",1,1)                //2
	oExcel:AddColumn(_planilha,_tab,"Item SC",1,1)                  //3
	oExcel:AddColumn(_planilha,_tab,"Produto SC",1,1)               //4
	oExcel:AddColumn(_planilha,_tab,"UM SC",1,1)                    //5
	oExcel:AddColumn(_planilha,_tab,"Descrição",1,1)                //6
	oExcel:AddColumn(_planilha,_tab,"Quantidade SC",1,1)            //7
	oExcel:AddColumn(_planilha,_tab,"Emissão SC",1,1)               //8
	oExcel:AddColumn(_planilha,_tab,"Data Necessidade  SC",1,1)     //9
	oExcel:AddColumn(_planilha,_tab,"Aprovada SC",1,1)              //10
	oExcel:AddColumn(_planilha,_tab,"Quantidade em Pedido",1,1)     //11
	oExcel:AddColumn(_planilha,_tab,"Conta Orçamentaria SC",1,1)    //12
	oExcel:AddColumn(_planilha,_tab,"Descr.C.Orçamentaria SC",1,1)  //12
	oExcel:AddColumn(_planilha,_tab,"Centro de Custo SC",1,1)       //13    
	oExcel:AddColumn(_planilha,_tab,"Descrição C.Custo SC",1,1)     //13    
	oExcel:AddColumn(_planilha,_tab,"Item Contabil SC",1,1)         //14
	oExcel:AddColumn(_planilha,_tab,"Descr.Item Contabil SC",1,1)   //14
	oExcel:AddColumn(_planilha,_tab,"Classe de Valor SC",1,1)       //15
	oExcel:AddColumn(_planilha,_tab,"Observação SC",1,1)            //16
	oExcel:AddColumn(_planilha,_tab,"Num Pedido PC",1,1)            //17
	oExcel:AddColumn(_planilha,_tab,"Item Pedido PC",1,1)            //17
	oExcel:AddColumn(_planilha,_tab,"Emissao PC",1,1)               //18
	oExcel:AddColumn(_planilha,_tab,"Condição Pagamento PC",1,1)    //19
	oExcel:AddColumn(_planilha,_tab,"Data Liberado PC",1,1)         //20
	oExcel:AddColumn(_planilha,_tab,"Fornecedor PC",1,1)            //21
	oExcel:AddColumn(_planilha,_tab,"Loja Fornecedor PC",1,1)       //22
	oExcel:AddColumn(_planilha,_tab,"Qauntidade PC",1,1)            //23
	oExcel:AddColumn(_planilha,_tab,"Quantidade Entregue PC",1,1)   //24
	oExcel:AddColumn(_planilha,_tab,"Total PC",1,1)                 //25
	oExcel:AddColumn(_planilha,_tab,"Comprado PC",1,1)  
    oExcel:AddColumn(_planilha,_tab,"(SC1)USUARIO APROV.",1,1)  
    oExcel:AddColumn(_planilha,_tab,"(SC1)NIVEL",1,1)   //24
    oExcel:AddColumn(_planilha,_tab,"(SC1)DATA APROV. NIVEL",1,1)                 //25
    oExcel:AddColumn(_planilha,_tab,"(SC7)USUARIO APROV.",1,1)  
    oExcel:AddColumn(_planilha,_tab,"(SC7)NIVEL(01)",1,1)   //24
    oExcel:AddColumn(_planilha,_tab,"(SC7)DATA APROV. NIVEL",1,1)                 //25
    oExcel:AddColumn(_planilha,_tab,"(SC7)USUARIO APROV.",1,1)  
    oExcel:AddColumn(_planilha,_tab,"(SC7)NIVEL(02)",1,1)   //24
    oExcel:AddColumn(_planilha,_tab,"(SC7)DATA APROV. NIVEL",1,1)                 //25
    oExcel:AddColumn(_planilha,_tab,"(SC7)USUARIO APROV.",1,1)  
    oExcel:AddColumn(_planilha,_tab,"(SC7)NIVEL",1,1)   //24
    oExcel:AddColumn(_planilha,_tab,"(SC7)DATA APROV. NIVEL",1,1)                 //25
                                       	
	for i:=1 to len(aDados)
		oExcel:AddRow(_planilha,_tab,aClone(aDados[i])) 
		
	next
	
	cNomeArq := "RelSc1XSc7"+STRTRAN(TIME(),":","")+".xml"
	_temp := gettemppath()
	oExcel:Activate()
	oExcel:GetXMLFile(_temp+cNomeArq)
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open( _temp+cNomeArq )
	oExcelApp:SetVisible(.T.)	
	
endif

return()

Static Function Input()
Local aPergs   := {}
Local cTitle     := "Parametros Solicitação de Compras "
local aRet       := {}
local bOk        := {|| .t.}
local aButtons   := {}
local lCentered  := .t.
local nPosX      := nil
local nPosY      := nil
local oDlgWizard := nil
Local cProgram   := "RELVIDASC"
local cLoad      := allTrim(cProgram) + ".pbx"
local lCanSave   := .t.
local lUserSave  := .t.
local okPress    := .f.
 
aAdd(aPergs, {1, "SC De? ",     Space(06)       ,  "@!", "", "SC1",     "", 80, .T.})
aAdd(aPergs, {1, "SC Até ",     Space(06)       ,  "@!", "", "SC1",     "", 80, .T.})
aAdd(aPergs, {1, "Emissao(SC) De",  CTOD(SPACE(8))  ,  "@D", "", "",     "", 80, .T.})
aAdd(aPergs, {1, "Emissao(SC) Até ",CTOD(SPACE(8))  ,  "@D", "", "",     "", 80, .T.})
aAdd(aPergs, {1, "Emissao(PC) De  ",CTOD(SPACE(8))  ,  "@D", "", "",     "", 80, .T.})
aAdd(aPergs, {1, "Emissao(PC) Até ",CTOD(SPACE(8))  ,  "@D", "", "",     "", 80, .T.})

	okPress := paramBox(aPergs ;		//Array: 	Array contendo as perguntas
	, cTitle ;		//Caracter:	Título da tela
	, aRet ;		//Array:	Array contendo as respostas
	, bOk ;			//Array:	Code block para validar o botão Ok
	, aButtons; 	//Array:	Array contendo definições dos botões opcionais, além dos botões de Ok e Cancel
	, lCentered ; 	//Lógico:	Indica se será centralizada a janela
	, nPosX ;		//Numérico:	Se não centralizar janela, coordenada X da janela
	, nPosY ;		//Numérico:	Se não centralizar janela, coordenada Y da janela
	, oDlgWizard ;	//Objeto: 	Objeto referente à janela ativa
	, cLoad ;		//Caracter:	Nome arquivo para gravar respostas
	, lCanSave ; 	//Lógico:	Indica se pode salvar o arquivo com respostas
	, lUserSave)	//Lógico:	Indica se salva nome do usuario no arquivo

	if !okPress
		return(.F.)
	endIf

Return(.T.)

