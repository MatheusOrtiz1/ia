#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³CTRFATUR  ºAutor  ³EVERTON FORTI      º Data ³  29/07/22   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³TELA PARA CONTROLE DE FATURAMENTO EMPRESA 28                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CONASA                                                     º±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CTRFATUR()
    Local oBrowse := FwLoadBrw("CTRFATUR")

    if !(SUBSTR(cnumemp,1,2) == '28')
        MSGINFO("Rotina habilitada somente para empresa 28 - "+SM0->M0_NOMECOM)
        return()
    ENDIF

    oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SERÁ ÚTIL PARA FUTURAS HERANÇAS: FWLOADBRW()
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("Z29")
    oBrowse:SetDescription("CONTROLE DE FATURAMENTO DIARIO")

    oBrowse:AddLegend("EMPTY(Z29_NMTRSG) .AND. EMPTY(Z29_NFISCA)", "RED", "Aberto")
    //oBrowse:AddLegend("!EMPTY(Z29_NMTRSG) _BXNMTR .AND. EMPTY(Z29_NFISCA)", "BLUE", "Aguardando Baixa MNTR")
    oBrowse:AddLegend("!EMPTY(Z29_NMTRSG) .AND. EMPTY(Z29_NFISCA)", "YELLOW", "Aguardando Faturamento")
    oBrowse:AddLegend("!EMPTY(Z29_NMTRSG) .AND. !EMPTY(Z29_NFISCA)", "GREEN" , "Faturado")

    //oBrowse:AddButton('Nota Faturada', {|| onpay()} ,, 7,)
    //oBrowse:AddButton('Importar', {|| U_IMPZ29()} ,, 7,)
   
   // DEFINE DE ONDE SERÁ RETIRADO O MENUDEF
   oBrowse:SetMenuDef("CTRFATUR")
Return (oBrowse)

// OPERAÇÕES DA ROTINA
Static Function MenuDef()
    // FUNÇÃO PARA CRIAR MENUDEF
    //Local aRotina := FWMVCMenu("CTRFATUR")
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE 'Visualizar'       ACTION 'VIEWDEF.CTRFATUR' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'          ACTION 'VIEWDEF.CTRFATUR' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'          ACTION 'VIEWDEF.CTRFATUR' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'          ACTION 'VIEWDEF.CTRFATUR' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'         ACTION 'VIEWDEF.CTRFATUR' OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE 'Copiar'           ACTION 'VIEWDEF.CTRFATUR' OPERATION 9 ACCESS 0
    ADD OPTION aRotina TITLE 'Cliente'          ACTION 'MATA030()' OPERATION 10 ACCESS 0
    ADD OPTION aRotina TITLE 'Tabela de Preco'  ACTION 'OMSA010()' OPERATION 10 ACCESS 0
    ADD OPTION aRotina TITLE 'Dados da Nota'    ACTION 'onpay()' OPERATION 10 ACCESS 0
    ADD OPTION aRotina TITLE 'Faturar'          ACTION 'U_CTRFAT01()' OPERATION 10 ACCESS 0
    ADD OPTION aRotina TITLE 'Importar'         ACTION 'U_IMPZ29()' OPERATION 10 ACCESS 0

Return (aRotina)

// REGRAS DE NEGÓCIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("COMP011M")

    // INSTANCIA O SUBMODELO
    Local oStruZ29 := FwFormStruct(1, "Z29")

    // DEFINE O SUBMODELO COMO FIELD
    oModel:AddFields("Z29MASTER", NIL, oStruZ29)

    // DESCRIÇÃO DO MODELO
    oModel:SetDescription("Controle de Faturamento Diário")

	//Define a chave primaria utilizada pelo modelo
	oModel:SetPrimaryKey({'Z29_FILIAL', 'Z29_ID'})

    // DESCRIÇÃO DO SUBMODELO
    oModel:GetModel("Z29MASTER"):SetDescription("Controle de Faturamento")
Return (oModel)

// INTERFACE GRÁFICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruZ29 := FwFormStruct(2, "Z29")

    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("CTRFATUR")

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_Z29", oStruZ29, "Z29MASTER")

    oView:AddGrid( 'VIEW_Z29', oStruZ29, 'ZA4DETAIL' )
    
    // CRIA BOX HORIZONTAL
    oView:CreateHorizontalBox("TELA" , 100)

    // RELACIONA OS BOX COM A ESTRUTURA VISUAL
    oView:SetOwnerView("VIEW_Z29", "TELA")
Return (oView)


//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description                                                     
                                                                
@param xParam Parameter Description                             
@return xRet Return Description                                 
@author Everton Forti - everton.forti@totvs.com.br                                              
@since 19/05/2022                                                   
/*/                                                             
//--------------------------------------------------------------
Static Function onpay()                        
Local cNota
Local npreco
Local nTotalM3
Local nToTm3
Local oButEnd
Local oButton1
Local oSay1
Local oSay2
Local totm3fret
Static oDlg
Private oGet1
Private cMES := SPACE(02)
Private oGet2
Private nPRECOM := SPACE(11)
Private oGet3
Private nVLRTOT := SPACE(11)
Private oGet4
Private nFRETE := SPACE(11)
Private oGet5
Private nTOTAL := SPACE(11)
Private oGet6
Private cNFISCAL := SPACE(09)
Private oGet7
Private cNOMECLI := SPACE(35)
Private LSAIU_ESC := .F.

    cMES        := Z29->Z29_MESFAT  
    nPRECOM     := Z29->Z29_PRECOM 
    nVLRTOT     := Z29->Z29_VLRTOT  
    nFRETE      := Z29->Z29_FRETE   
    nTOTAL      := Z29->Z29_TOTAL   
    cNFISCAL    := Z29->Z29_NFISCA
    cNOMECLI    := Z29->Z29_FTPARA  


DEFINE MSDIALOG oDlg TITLE "Informe os Dados do Faturamento" FROM 000, 000  TO 300, 650 COLORS 0, 16777215 PIXEL

    @ 023, 018 MSGET oGet1 VAR cMES PICTURE "@! 99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 051, 018 MSGET oGet2 VAR nPRECOM PICTURE "@E 99,999,999.99" SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 051, 102 MSGET oGet3 VAR nVLRTOT PICTURE "@E 99,999,999.99"SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 051, 186 MSGET oGet4 VAR nFRETE PICTURE "@E 99,999,999.99"SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 051, 258 MSGET oGet5 VAR nTOTAL PICTURE "@E 99,999,999.99"SIZE 060, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 080, 018 MSGET oGet6 VAR cNFISCAL  PICTURE "@! 999999999" SIZE 058, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 080, 102 MSGET oGet7 VAR cNOMECLI SIZE 210, 010 OF oDlg COLORS 0, 16777215 PIXEL
    @ 013, 018 SAY oSay1 PROMPT "Mês" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 018 SAY npreco PROMPT "Preço por m³" SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 102 SAY nToTm3 PROMPT "Valor Total m³" SIZE 056, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 188 SAY nTotalM3 PROMPT "Venda Frete" SIZE 044, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 040, 260 SAY totm3fret PROMPT "Tot.M³ + Frete" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 071, 018 SAY cNota PROMPT "Nota Fiscal" SIZE 051, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 071, 102 SAY oSay2 PROMPT "Nome do Cliente" SIZE 063, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 117, 215 BUTTON oButton1 PROMPT "Confirma" SIZE 065, 012 OF oDlg PIXEL ACTION (IIF(CONFOK(),(LSAIU_ESC:=.T.,oDlg:END()),))
    @ 117, 023 BUTTON oButEnd PROMPT "Cancela" SIZE 037, 012 OF oDlg PIXEL ACTION (LSAIU_ESC:=.T.,oDlg:END())

  ACTIVATE MSDIALOG oDlg CENTERED

Return

//*************************************
//função CONFIRMA tela ODLG    //
//*************************************
Static Function CONFOK()
Local lRet  := .T.

IF RECLOCK("Z29",.F.)
    Z29->Z29_MESFAT := cMES
    Z29->Z29_PRECOM := nPRECOM
    Z29->Z29_VLRTOT := nVLRTOT
    Z29->Z29_FRETE  := nFRETE
    Z29->Z29_TOTAL  := nTOTAL
    Z29->Z29_NFISCA := cNFISCAL
    Z29->Z29_FTPARA := cNOMECLI
    IF !EMPTY(cNFISCAL)
    Z29->Z29_STATUS := '2'
    ELSE
    Z29->Z29_STATUS := '1'
    ENDIF
    MSUNLOCK()
ENDIF

RETURN lRet
//*************************************
//função para said da tela ODLG    //
//*************************************
STATIC FUNCTION SAIDA()

	LOCAL LRET := .T.

	IF !LSAIU_ESC
		LRET := .F.
	ENDIF


RETURN(LRET)

USER FUNCTION Z29NEWID()
Local cQuery    := ""
Local cdatahj   := ANOMES(DDATABASE)
Local cNEWID    := ANOMES(DDATABASE)+'0001'
lOCAL cIdtmp    := "0000"

	cQuery := " SELECT MAX(Z29_ID) AS Z29_ID "
	cQuery += " FROM "+RetSqlName("Z29") + " Z29"
	cQuery += " WHERE  Z29_DATA >= '"+cdatahj+"01' AND Z29_DATA <= '"+cdatahj+"31' "
	cQuery += " AND Z29_FILIAL =  '"+ xFilial("Z29") +"'AND Z29.D_E_L_E_T_='' "
			IF SELECT("OSTEMP")!=0
				OSTEMP->(DBCLOSEAREA())
			ENDIF	
	TCQUERY cQuery NEW ALIAS "OSTEMP"

    dbselectarea("OSTEMP")
IF OSTEMP->(!eof()) .and. !EMPTY(OSTEMP->Z29_ID)

    cIdtmp := SOMA1(SUBSTR(OSTEMP->Z29_ID,6,4))
    cNEWID := ANOMES(DDATABASE)+cIdtmp

ENDIF
OSTEMP->(DBCLOSEAREA())


RETURN cNEWID

USER FUNCTION TIPOZ29()

AXCADASTRO("Z28","TIPO E SUBTIPO")

RETURN(.T.)

USER FUNCTION CADOBSZ29()

AXCADASTRO("Z27","OBSERVAÇÃO")

RETURN(.T.)

//*************************************
//Cria Mark Browser                   //
//*************************************




//*************************************
//GERA PEDIDO DE VENDA               //
//*************************************
User Function CTRFAT01()

Local aCabec := {}
Local aItens := {}
Local nX := {}
Private cDoc := getSxeNum("SC5", "C5_NUM")
Private lMsErroAuto := .F.
confirmSX8()
 aCabec := {}
 aItens := {}
 aadd(aCabec,{"C5_NUM",cDoc,Nil})
 aadd(aCabec,{"C5_TIPO","N",Nil})
 aadd(aCabec,{"C5_CLIENTE",SA1->A1_COD,Nil})
 aadd(aCabec,{"C5_LOJACLI",SA1->A1_LOJA,Nil})
 aadd(aCabec,{"C5_LOJAENT",SA1->A1_LOJA,Nil})
 aadd(aCabec,{"C5_CONDPAG",SE4->E4_CODIGO,Nil})
 
 For nX := 1 To 3
 aLinha := {}
 
 If nX == 1
 aadd(aLinha,{"LINPOS","C6_ITEM",StrZero(nX,2)})
 aadd(aLinha,{"AUTDELETA","S",Nil})
 Else
 aadd(aLinha,{"AUTDELETA","N",Nil})
 EndIf 
 aadd(aLinha,{"C6_ITEM",StrZero(nX,2),Nil})
 aadd(aLinha,{"C6_PRODUTO","PROD00000000000",Nil})
 aadd(aLinha,{"C6_QTDVEN",3,Nil})
 aadd(aLinha,{"C6_PRCVEN",100,Nil})
 aadd(aLinha,{"C6_PRUNIT",100,Nil})
 aadd(aLinha,{"C6_VALOR",300,Nil})
 aadd(aLinha,{"C6_TES","501",Nil})
 
 aadd(aItens,aLinha)
 Next nX
 ConOut(PadC("Teste de alteracao",80))
 ConOut("Inicio: "+Time())
 MSExecAuto({|x,y,z|mata410(x,y,z)},aCabec,aItens,4)
 ConOut("Fim : "+Time())
 ConOut(Repl("-",80))

If !lMsErroAuto

ConOut("Incluido com sucesso! ") 

Else 
 ConOut("Erro na inclusao!")
 Mostraerro()
 
EndIf

REturn()


