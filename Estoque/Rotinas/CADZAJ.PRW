#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"

/*
Programa.: CADZAJ.prw 
Tipo.....: Atualização 
Autor....: Daniel Gouvea - TOTVS Unidade Londrina
Data.....: 11/04/2023
Descrição: Cadastro de Usuario x Local
Notas....:   
*/

static oAlerts   := tcAlerts():New()	//Instanciando a classe para controle de mensagens
static cProgram  := "CADZAJ"			//Nome da função principal para chamada externa do programa 
static cTitle  	 := "Cadastro de Usuario x Local"			//Título do programa

user function CADZAJ()
	local aArea := getArea()
	
    //private oAlerts := pfwAlerts():New()
    private oUtils  := pfwUtils():New()
	private oBrowse := nil

	oBrowse := fwMBrowse():New()
	oBrowse:SetAlias("ZAJ")
	oBrowse:SetDescription(cTitle)
	oBrowse:Activate()

    oUtils:Destroy()
    oAlerts:Destroy()

	restArea(aArea)
return

static function menuDef()
	local aRot := {}
	
	//Adicionando opções
	add option aRot title 'Visualizar' action 'ViewDef.' + cProgram operation 1 access 0
	add option aRot title 'Incluir'    action 'ViewDef.' + cProgram operation 3 access 0
	add option aRot title 'Alterar'    action 'ViewDef.' + cProgram operation 4 access 0
	add option aRot title 'Excluir'    action 'ViewDef.' + cProgram operation 5 access 0
return(aRot)

static function modelDef()
	local oModel  := nil
	local oStrZAJ := fwFormStruct(1, 'ZAJ')  
	    
	oModel := mpFormModel():New('MainModel', /*{|oModel| preValidDef(oModel)}*/ ;	//Pré-validação do modelo
											  , {|oModel| validDef(oModel)} ;		//Validação do modelo (Equilave ao "TUDOOK")
											  , {|oModel| saveDef(oModel)} ;		//Gravação da edição do registro (Commit)
											  , /*{|oModel| cancelDef(oModel)}*/)	//Cancelamento da edição do registro
	oModel:SetDescription(cTitle)
	oModel:addFields('mFormZAJ',, oStrZAJ)
	oModel:SetPrimaryKey({"ZAJ_FILIAL", "ZAJ_USUARI"})
    
	oModel:getModel('mFormZAJ'):SetDescription(cTitle)
return(oModel)

static function viewDef()
	local oView	  := nil
	local oModel  := modelDef()
	local oStrZAJ := fwFormStruct(2, 'ZAJ')	
	
	oView := fwFormView():New()
	oView:SetModel(oModel)
	oView:AddField('formZAJ', oStrZAJ, 'mFormZAJ')
	oView:CreateHorizontalBox('boxZAJ', 100)
	oView:SetOwnerView('formZAJ', 'boxZAJ')
	oView:SetCloseOnOk({|| .t.})
return(oView)

static function validDef(oModel)
	local areaZAJ   := ZAJ->(getArea())
	//local oModelZAJ := oModel:GetModel('mFormZAJ')
	local nOpc      := oModel:GetOperation()

	oAlerts:Empty()
			
	if nOpc == 3		//Insert 
	endIf

	if nOpc == 4		//Update
	endIf 
	
	if nOpc == 3 .or. nOpc == 4		//Upsert
	
	endIf
	
	if nOpc == 5		//Delete
   
	endIf
	
	restArea(areaZAJ)
	fwModelActive(oModel, .t.)

	oAlerts:Show()
	if oAlerts:HasErrors()
	    if nOpc != 5		//Delete
            help(,,, "Validação de Dados", "Dados inconsistentes em campos do formulário.", 1, 1,,,,, .f., {"Corrija as inconsistências apresentadas anteriormente para efetivação do registro."})
        else
            help(,,, "Validação de Dados", "Eliminação de registro cancelada.", 1, 1,,,,, .f., {"O registro selecionado não pode ser eliminado, verifique as regras e relacionamentos existentes."})
        endIf
	endIf
return(!oAlerts:HasErrors())

static function saveDef(oModel)
	local lReturn := .t.

	begin transaction
		lReturn := fwFormCommit(oModel)		//Efetua a gravação padrão do modelo de dados
		
		if !lReturn
			disarmTransaction()
		endIf
	end transaction
	
	//Depois de gravar
return(lReturn)
