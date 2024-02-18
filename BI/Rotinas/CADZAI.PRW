#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"

/*
Programa.: CADZAI.prw 
Tipo.....: Atualização 
Autor....: Daniel Gouvea - TOTVS OESTE - Unidade Londrina
Data.....: 01/08/2023
Descrição: CADASTRO TERCEIROS
Notas....:   
*/

static oAlerts   := pfwAlerts():New()	//Instanciando a classe para controle de mensagens
static cProgram  := "CADZAI"			//Nome da função principal para chamada externa do programa
static cTitle  	 := "Cadastro Terceiros"			//Título do programa

//-------------------------------------------------------------------
user function CADZAI()
	local aArea := getArea()

	private oBrowse := nil

	oBrowse := fwMBrowse():New()		//Instanciando o objeto browse

	oBrowse:SetAlias("ZAI")				//Setando a tabela
	oBrowse:SetDescription(cTitle)		//Setando a descrição da rotina

	oBrowse:Activate()		//Ativação do browser

	restArea(aArea)
return


static function menuDef()
	local aRot := {}

	//Adicionando opções
	add option aRot title 'Visualizar'   action 'ViewDef.' + cProgram operation 1 access 0
	add option aRot title 'Incluir'      action 'ViewDef.' + cProgram operation 3 access 0
	add option aRot title 'Alterar'      action 'ViewDef.' + cProgram operation 4 access 0
	add option aRot title 'Excluir'      action 'ViewDef.' + cProgram operation 5 access 0
	add option aRot title 'Importar CSV' action 'U_IMPZAI'            operation 3 access 0

return(aRot)


User FUNCTION IMPZAI
	Private cTitulo1	:= "Selecione o arquivo"
	Private cExtens		:= ""
	Private	cFileOpen 	:= ""
	Private cEOL    	:= "CHR(13)+CHR(10)"
	Private cPerg       := "IMPZAI  "

	if !pergunte(cPerg,.T.)
		return
	endif

	If !File(MV_PAR01)
		MsgAlert("Arquivo texto: "+MV_PAR01+" não localizado","IMPZAI")
		Return
	Endif

	Processa({|| RunCont(MV_PAR01) },"Processando...")
RETURN

static Function RunCont(cFileOpen)
	Local cBuffer 			:= ""
	Local ni,cID
	Local cLog := ''
	Private aDados			:= {}
	//Private aDados		:= {}
	Private aNEncontrados	:= {}
	Private Linha

	FT_FUSE(cFileOpen) //ABRIR
	FT_FGOTOP() //PONTO NO TOPO
    cBuffer := FT_FREADLN() //LENDO LINHA CABECALHO
	FT_FSKIP() //próximo registro no arquivo txt

	While !FT_FEOF() //FACA ENQUANTO NAO FOR FIM DE ARQUIVO
		IncProc()

		If FT_FLastRec() == 1
			FT_FSkip()
		endif

		IncProc() // Capturar dados		

		cBuffer := FT_FREADLN() //LENDO LINHA


		//Tratativa para retirar caracteres especiais
		cBuffer := STRTRAN(cBuffer,'""',"")
		cBuffer := STRTRAN(cBuffer,"ï","")
		cBuffer	:= STRTRAN(cBuffer,"¿","")
		cBuffer := STRTRAN(cBuffer,"»","")
		cBuffer := STRTRAN(cBuffer,"-","")
		cBuffer := STRTRAN(cBuffer,"?","")
		cBuffer := STRTRAN(cBuffer,"!","")
		cBuffer := STRTRAN(cBuffer,"^","")
		cBuffer := STRTRAN(cBuffer,"é","e")
		cBuffer := STRTRAN(cBuffer,"õ","o")
		cBuffer := STRTRAN(cBuffer,"Ã","A")
		cBuffer := STRTRAN(cBuffer,"©","o")
		cBuffer := STRTRAN(cBuffer,"ã","a")
		cBuffer := STRTRAN(cBuffer,"ã","a")
		cBuffer := UPPER(cBuffer)

		aAux:= StrTokArr2(cBuffer, ";",.T.)
		if len(aAux)>=8
			aadd(aDados,{aAux[1],STRZERO(VAL(aAux[2]),2),aAux[3],aAux[4],aAux[5],aAux[6],aAux[7],aAux[8],aAux[9]})
		endif
		FT_FSKIP() //próximo registro no arquivo txt
	EndDo

	FT_FUSE() //fecha o arquivo txt

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
//³ cao anterior.                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cID := getSX8Num("ZAI", "ZAI_ID")
	confirmSX8()
	For ni := 1 To Len(aDados)


		DbSelectArea("ZAI")
		dbsetorder(3)//ZAI_FILIAL+ZAI_CPF+ZAI_MES_ZAI_ANO+ZAI_ID
		if dbseek(xFilial()+aDados[ni,1]+aDados[ni,2]+aDados[ni,3])
			cLog += "REGISTRO DUPLICADO. CPF "+aDados[ni,6]+" MES "+aDados[ni,2]+" ANO "+aDados[ni,3]+chr(13)+chr(10)
		else
			if reclock("ZAI",.T.)
				ZAI->ZAI_FILIAL := xFilial()
				ZAI->ZAI_ID     := cID
				ZAI->ZAI_CNPJ   := aDados[ni,1]
				ZAI->ZAI_MES    := aDados[ni,2]
				ZAI->ZAI_ANO    := aDados[ni,3]
				ZAI->ZAI_EMPRES := aDados[ni,4]
				ZAI->ZAI_NOME   := aDados[ni,5]
				ZAI->ZAI_CPF    := aDados[ni,6]
				ZAI->ZAI_SALARI   := VAL(STRTRAN(STRTRAN(aDados[ni,7],",","."),".",""))
				ZAI->ZAI_FUNCAO := aDados[ni,8]
                ZAI->ZAI_LOCALP := aDados[ni,9]
				msunlock()
				cLog += "IMPORTADO CPF "+aDados[ni,6]+" MES "+aDados[ni,2]+" ANO "+aDados[ni,3]+chr(13)+chr(10)
			endif
		endif

	Next nI

	DEFINE MSDIALOG oDlg TITLE "Log importação" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL
	@ 020,010 Get cLog Size 230,100 MEMO of oDlg Pixel
	@ 128, 179 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL ACTION ODLG:END()
	ACTIVATE MSDIALOG oDlg CENTERED

Return

static function modelDef()
	local oModel  := nil
	local oStrZAI := fwFormStruct(1, 'ZAI')

	oModel := mpFormModel():New('MainModel', /*{|oModel| preValidDef(oModel)}*/ ;	//Pré-validação do modelo
	, {|oModel| validDef(oModel)} ;		//Validação do modelo (Equilave ao "TUDOOK")
	, {|oModel| saveDef(oModel)} ;		//Gravação da edição do registro (Commit)
	, /*{|oModel| cancelDef(oModel)}*/)	//Cancelamento da edição do registro
	oModel:SetDescription(cTitle)

	//Criação de objetos de interface
	oModel:addFields('MFieldZAI',, oStrZAI)

	//Definindo propriedades de atributos (campos) em tela
//	oStrZCA:SetProperty("ZAJ_CODSAF" , MODEL_FIELD_WHEN, {|| INCLUI})

	oModel:SetPrimaryKey({"ZAI_FILIAL", "ZAI_ID"})		//Indicando índice primário

	//Informando as descrições para os modelos de dados
	oModel:getModel('MFieldZAI'):SetDescription(cTitle)
return(oModel)


//-------------------------------------------------------------------
/*/{Protheus.doc} viewDef
Definição do interface
@author Odair Batista - TOTVS Unidade Londrina
@since 05/07/2018
@version 1.0
@type function
@return oView, objeto, View de interface
/*/
//-------------------------------------------------------------------
static function viewDef()
	local oView	  := nil
	local oModel  := modelDef()
	local oStrZAI := fwFormStruct(2, 'ZAI')


	oView := fwFormView():New()		//Instanciando a Viewer para interface

	oView:SetModel(oModel)			//Indicando o modelo de dados para a Viewer

	//Adicionando objetos de interface
	oView:AddField('formZAI', oStrZAI, 'MFieldZAI')

	oView:CreateHorizontalBox('boxZAI', 100)

	oView:SetOwnerView('formZAI', 'boxZAI')

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({|| .t.})
return(oView)


static function validDef(oModel)
	local areaZAI   := ZAI->(getArea())
	//local oModelZAI := oModel:GetModel('MFieldZAI')
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

	restArea(areaZAI)


	fwModelActive(oModel, .t.)

	oAlerts:Show()

	if oAlerts:HasErrors()
		help("", 1, "Erro ao validar dados",, "Existem campos com dados inconsistentes", 4, 8, .f.)
	endIf
return(!oAlerts:HasErrors())

static function saveDef(oModel)
	local lReturn := .t.

	//Antes de gravar

	begin transaction
		lReturn := fwFormCommit(oModel)		//Efetua a gravação padrão do modelo de dados

		if !lReturn
			disarmTransaction()
		endIf
	end transaction

	//Depois de gravar
return(lReturn)
