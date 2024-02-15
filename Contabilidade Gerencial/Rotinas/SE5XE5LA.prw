#Include "PROTHEUS.CH"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "FWMVCDEF.ch"
/*
�������������������������������������������������������������������������͹��
���Descricao: SE5XE5LA -  Desmarca Contabiliza��o do Mocimento bancario   ���
�����������������������������������������������������������������������������
���Author: Everton Forti       Uso: Conasa         Data: 01/06/2022       ���
�����������������������������������������������������������������������������
*/
// FUN��O PRINCIPAL
User Function SE5XE5LA()
    Local oBrowse := FwLoadBrw("SE5XE5LA")

    oBrowse:Activate()
Return (NIL)

// BROWSEDEF() SER� �TIL PARA FUTURAS HERAN�AS: FWLOADBRW()
Static Function BrowseDef()
    Local oBrowse := FwMBrowse():New()

    oBrowse:SetAlias("SE5")
    oBrowse:SetDescription("DESMARCA CONTABILIZACAO MOVIMENTO BANCARIO")

    oBrowse:AddLegend("EMPTY(E5_LA)", "GREEN", "N�o Contabilizado")
    oBrowse:AddLegend("!EMPTY(E5_LA)", "RED", "Contabilizado")

   // DEFINE DE ONDE SER� RETIRADO O MENUDEF
   oBrowse:SetMenuDef("SE5XE5LA")

Return (oBrowse)
// OPERA��ES DA ROTINA
Static Function MenuDef()
    // FUN��O PARA CRIAR MENUDEF
    //Local aRotina := FWMVCMenu("SE1XE1LA")
    Local aRotina := {}
    
    ADD OPTION aRotina TITLE 'Visualizar'                   ACTION 'VIEWDEF.SE5XE5LA' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Desmarca Linha'               ACTION 'U_SE5XLA()' OPERATION 10 ACCESS 0
    //ADD OPTION aRotina TITLE 'Desmarca Contabiliza��o'      ACTION 'U_Desmarc()' OPERATION 10 ACCESS 0

    //Adicionando op��es
	//ADD OPTION aRotina TITLE 'Faturamento' ACTION 'VIEWDEF.zMVCMdX' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1

Return (aRotina)
// REGRAS DE NEG�CIO
Static Function ModelDef()
    // INSTANCIA O MODELO
    Local oModel := MPFormModel():New("COMP011M")

    // INSTANCIA O SUBMODELO
    Local oStruSE5 := FwFormStruct(1, "SE5")

    // DEFINE O SUBMODELO COMO FIELD
    oModel:AddFields("SE5MASTER", NIL, oStruSE5)

    // DESCRI��O DO MODELO
    oModel:SetDescription("Desmarca Contabiliza��o Movimento Bancario")

	//Define a chave primaria utilizada pelo modelo
    oModel:SetPrimaryKey({'E5_FILIAL','E5_PREFIXO','E5_NUMERO','E5_PARCELA','E5_TIPO','E5_CLIFOR','E5_LOJA','E5_SEQ'})

    // DESCRI��O DO SUBMODELO
    oModel:GetModel("SE5MASTER"):SetDescription("Desmarca Contabiliza��o Movimento Bancario")
Return (oModel)

// INTERFACE GR�FICA
Static Function ViewDef()
    // INSTANCIA A VIEW
    Local oView := FwFormView():New()

    // INSTANCIA AS SUBVIEWS
    Local oStruSE5 := FwFormStruct(2, "SE5")

    // RECEBE O MODELO DE DADOS
    Local oModel := FwLoadModel("SE5XE5LA")

    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    // CRIA ESTRUTURA VISUAL DE CAMPOS
    oView:AddField("VIEW_SE5", oStruSE5, "SE5MASTER")

    // CRIA BOX HORIZONTAL
    oView:CreateHorizontalBox("TELA" , 100)

    // RELACIONA OS BOX COM A ESTRUTURA VISUAL
    oView:SetOwnerView("VIEW_SE5", "TELA")
Return (oView)

User Function SE5XLA()

IF !EMPTY(SE5->E5_LA)
    IF RECLOCK("SE5",.F.)
        SE5->E5_LA = " "
    MSUNLOCK()
    ENDIF
    
    MSGINFO( "Registro Desmarcado, favor recontabilizar!", "Sucesso" )

ENDIF

RETURN
