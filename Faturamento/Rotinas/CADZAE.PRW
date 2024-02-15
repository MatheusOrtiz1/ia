#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"

/*
Programa.: CADZAE.prw 
Tipo.....: Atualização 
Autor....: Daniel Gouvea - TOTVS OESTE - Unidade Londrina
Data.....: 03/11/2022
Descrição: INTEGRACAO FATURAMENTO
Notas....:   
*/

static oAlerts   := pfwAlerts():New()	//Instanciando a classe para controle de mensagens
static cProgram  := "CADZAE"			//Nome da função principal para chamada externa do programa
static cTitle  	 := "Integração Faturamento"			//Título do programa


//-------------------------------------------------------------------
user function CADZAE()
	local aArea := getArea()

	private oBrowse := nil

	oBrowse := fwMBrowse():New()		//Instanciando o objeto browse

	oBrowse:SetAlias("ZAE")				//Setando a tabela
	oBrowse:SetDescription(cTitle)		//Setando a descrição da rotina

	//Adicionando as Legendas
    oBrowse:AddLegend( "ZAE->ZAE_STATUS == ' ' ", "GREEN"	,    "Aguardando Processamento" )
    oBrowse:AddLegend( "ZAE->ZAE_STATUS == 'P' ", "BLUE"	,    "Processando" )
    oBrowse:AddLegend( "ZAE->ZAE_STATUS == 'F' ", "YELLOW"	,    "Faturamento Finalizado" )
    oBrowse:AddLegend( "ZAE->ZAE_STATUS == 'E' ", "RED"		,    "Erro no Faturamento" )
 

	oBrowse:Activate()		//Ativação do browser

	restArea(aArea)
return


static function menuDef()
	local aRot := {}

	//Adicionando opções
	add option aRot title 'Visualizar'  action 'ViewDef.' + cProgram operation 1 access 0
	add option aRot title 'Reprocessar' action 'U_REPRZAE'  operation 2 access 0
	add option aRot title 'Importar'    action 'U_IMPORZAE' operation 3 access 0
	add option aRot title 'Processar'    action 'U_PROCZAE' operation 4 access 0
return(aRot)


User Function REPRZAE
if ZAE->ZAE_STATUS=='E'
	IF RECLOCK("ZAE",.F.)
		ZAE->ZAE_STATUS := ""
		ZAE->ZAE_LOGERR := "" 
		MSUNLOCK()
	ENDIF 
	U_PROCZAE()
ENDIF 
return

static function modelDef()
	local oModel  := nil
	local oStrZAE := fwFormStruct(1, 'ZAE')

	oModel := mpFormModel():New('MainModel', /*{|oModel| preValidDef(oModel)}*/ ;	//Pré-validação do modelo
	, {|oModel| validDef(oModel)} ;		//Validação do modelo (Equilave ao "TUDOOK")
	, {|oModel| saveDef(oModel)} ;		//Gravação da edição do registro (Commit)
	, /*{|oModel| cancelDef(oModel)}*/)	//Cancelamento da edição do registro
	oModel:SetDescription(cTitle)

	//Criação de objetos de interface
	oModel:addFields('MFieldZAE',, oStrZAE)

	//Definindo propriedades de atributos (campos) em tela
//	oStrZCA:SetProperty("ZAJ_CODSAF" , MODEL_FIELD_WHEN, {|| INCLUI})

	oModel:SetPrimaryKey({"ZAE_FILIAL", "ZAE_EVENTO","ZAE_ORIGEM","DTOS(ZAE_DATA)"})		//Indicando índice primário

	//Informando as descrições para os modelos de dados
	oModel:getModel('MFieldZAE'):SetDescription(cTitle)
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
	local oStrZAE := fwFormStruct(2, 'ZAE')


	oView := fwFormView():New()		//Instanciando a Viewer para interface

	oView:SetModel(oModel)			//Indicando o modelo de dados para a Viewer

	//Adicionando objetos de interface
	oView:AddField('formZAE', oStrZAE, 'MFieldZAE')

	oView:CreateHorizontalBox('boxZAE', 100)

	oView:SetOwnerView('formZAE', 'boxZAE')

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({|| .t.})
return(oView)


static function validDef(oModel)
	local areaZAE   := ZAE->(getArea())
	//local oModelZAE := oModel:GetModel('MFieldZAE')
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

	restArea(areaZAE)


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

USER FUNCTION IMPORZAE()
	Local i
	Private cPerg := "IMPORZAE"
	Private aDados := {}
	validperg()

	if !pergunte(cPerg,.T.)
		return
	endif

	If File(alltrim(MV_PAR01))
		FT_FUse(MV_PAR01)
		FT_FGotop()
		cLinha := FT_FReadLn()
		FT_FSkip()//PULA O CABECALHO
		cLinha := ""
		aDados := {}
		aLinha := {}
		_CONT := 0

		procregua(FT_FLASTREC())
		While !FT_FEOF()
			incproc("Lendo Arquivo...")
			_CONT++
			cLinha := FT_FReadLn()

			cLinha := upper(cLinha)
			cLinha := noAcento(cLinha)
			cLinha := strtran(cLinha,"	","")
			_auxIni := 1
			_auxFim := 1
			while _auxFim<=len(cLinha)
				if substr(cLinha,_auxFim,1) == "|"
					aadd(aLinha,alltrim(substr(cLinha,_auxIni,_auxFim-_auxIni)))
					_auxFim++
					_auxIni := _auxFim
				else
					_auxFim++
				endif
			enddo

			aadd(aLinha,substr(cLinha,_auxIni,_auxFim-_auxIni))
			aadd(aDados,aLinha)
			aLinha := {}
			FT_FSkip()
		EndDo

		FT_FUse()
	else
		MSGINFO("Arquivo não encontrado. Favor verificar os parametros.")
	endif

	i:=1
    /*
	layout 1
    1 - Evento
    2 - Origem
    3 - Data
    4 - Descrição
    5 - Conta Credito
    6 - Conta Debito
    7 - Valor 1
	8 - Valor 2
	9 - Valor 3
	10- Valor 4

	layout 2
	1 CODIGO LOCALIDADE 
	2 LOCALIDADE_NOME
	3 DATA_CONTABIL
	4 TIPO
	5 VALOR AGUA
	6 VALOR ESGOTO
	7 VALOR IR
	8 VALOR COFINS
	9 VALOR CSLL
	10 VALOR PIS
	11 VALOR JUROS
	12 VALOR SERVICOS
	13 VALOR CANCELADO	
    */
	cMsg :=""
	nCont := 0
	nContN := 0
	_valor := 0
	_valor2 := 0
	_valor3 := 0
	_valor4 := 0
	for i:=1 to len(aDados)


		if MV_PAR02==1 //LAYOUT 1
			_evento   := alltrim(aDados[i,1])
			_origem   := alltrim(aDados[i,2])
			_data     := substr(aDados[i,3],7,4)+substr(aDados[i,3],4,2)+substr(aDados[i,3],1,2)
			_valor    := val(strtran(aDados[i,7],",","."))
			if len(aDados[i])>7
				_valor2   := val(strtran(aDados[i,8],",","."))
			endif
			if len(aDados[i])>8
				_valor3   := val(strtran(aDados[i,9],",","."))
			endif
			if len(aDados[i])>9
				_valor4   := val(strtran(aDados[i,10],",","."))
			endif
			_chave := _evento+_origem+_data
		ELSE
			_sequencia := alltrim(aDados[i,1])
			_data      := substr(aDados[i,7],7,4)+substr(aDados[i,7],4,2)+substr(aDados[i,7	],1,2)
			_valAgua   := val(strtran(aDados[i,5],",","."))
			_valEsgoto := val(strtran(aDados[i,6],",","."))
			_valIR     := val(strtran(aDados[i,7],",","."))
			_valCofins := val(strtran(aDados[i,8],",","."))
			_valCSLL   := val(strtran(aDados[i,9],",","."))
			_valPIS    := val(strtran(aDados[i,10],",","."))
			_valJuros  := val(strtran(aDados[i,11],",","."))
			_valServ   := val(strtran(aDados[i,12],",","."))
			_valCanc   := val(strtran(aDados[i,13],",","."))

			//data+tipo+cidade
			_chave := _data+alltrim(aDados[i,4])+alltrim(aDados[i,1])
		ENDIF
		dbselectarea("ZAF")
		dbsetorder(1)//ZAF_FILIAL+ZAF_EVENTO+ZAF_ORIGEM
		if dbseek(xFilial()+_evento+_origem)
			dbselectarea("ZAE")
			dbsetorder(4)//ZAE_FILIAL+ZAE_CHAVE
			if dbseek(xFilial()+_chave)
				cMsg += " Registro "+_chave+" já foi importado. Registro ignorado na importação. "+chr(13)+chr(10)
				nContN +=1
			else
				IF MV_PAR02==2 //LAYOUT 2
					
				
				ENDIF 
				if reclock("ZAE",.T.)
					ZAE->ZAE_FILIAL := xFilial()
					ZAE->ZAE_CHAVE  := _chave
					ZAE->ZAE_CLIENT := ZAF->ZAF_CLIENT
					ZAE->ZAE_LOJA   := ZAF->ZAF_LOJA
					ZAE->ZAE_COND   := ZAF->ZAF_COND
					ZAE->ZAE_NATURE := ZAF->ZAF_NATURE
					ZAE->ZAE_HISTCR := ZAF->ZAF_HISTCR
					ZAE->ZAE_CCUSTO := ZAF->ZAF_CCUSTO					
					ZAE->ZAE_CRED   := ZAF->ZAF_CRED  
					ZAE->ZAE_DEB    := ZAF->ZAF_DEB   
					ZAE->ZAE_CCDEB  := ZAF->ZAF_CCDEB 
					ZAE->ZAE_CCCRED := ZAF->ZAF_CCCRED
					ZAE->ZAE_BANCO  := ZAF->ZAF_BANCO 
					ZAE->ZAE_AGENCI := ZAF->ZAF_AGENCI
					ZAE->ZAE_CONTA  := ZAF->ZAF_CONTA 
					ZAE->ZAE_ITEMCT := ZAF->ZAF_ITEMCT
					ZAE->ZAE_CLVL   := ZAF->ZAF_CLVL
					ZAE->ZAE_DATA   := stod(_data)
					ZAE->ZAE_DTINT  := date()
					ZAE->ZAE_HRINT  := time()
					ZAE->ZAE_TIPO   := ZAF->ZAF_TIPO
					ZAE->ZAE_EVENTO := ZAF->ZAF_EVENTO
					ZAE->ZAE_SERIE  := ZAF->ZAF_SERIE
					ZAE->ZAE_ORIGEM := ZAF->ZAF_ORIGEM
					ZAE->ZAE_COD    := ZAF->ZAF_COD
					ZAE->ZAE_TES    := ZAF->ZAF_TES
					ZAE->ZAE_PRECO  := abs(_valor)
					if _valor2>0
						ZAE->ZAE_COD2   := ZAF->ZAF_COD2
						ZAE->ZAE_TES2   := ZAF->ZAF_TES2
						ZAE->ZAE_PRECO2 := ZAF->ZAF_PRECO2
					endif
					if _valor3>0
						ZAE->ZAE_COD3   := ZAF->ZAF_COD3
						ZAE->ZAE_TES3   := ZAF->ZAF_TES3
						ZAE->ZAE_PRECO3 := ZAF->ZAF_PRECO3
					endif
					if _valor4>0
						ZAE->ZAE_COD4   := ZAF->ZAF_COD4
						ZAE->ZAE_TES4   := ZAF->ZAF_TES4
						ZAE->ZAE_PRECO4 := ZAF->ZAF_PRECO4
					endif
					msunlock()
				endif
				nCont += 1
			endif
		else
			cMsg += " Evento "+_evento+" origem "+_origem+" não encontrados. Registro ignorado na importação. "+chr(13)+chr(10)
			nContN +=1
		endif

	next

	cResumo := " Registros totais: "+cvaltochar(len(aDados))+". Registros processados: "+CValToChar(nCont)+". Registros Ignorados: "+CValToChar(nContN)
	DEFINE MSDIALOG oDlg TITLE "Log importação" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL
	@ 005, 005 SAY oSay1 PROMPT cResumo SIZE 200, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 020,010 Get cMsg Size 230,100 MEMO of oDlg Pixel
	@ 128, 179 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL ACTION ODLG:END()
	ACTIVATE MSDIALOG oDlg CENTERED

return

Static Function ValidPerg()
	local i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}
	aAdd(aRegs,{cPerg,"01","Arquivo a Importar ?","","","mv_ch1","C",60,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Layout ?","","","mv_ch1","N",01,0,0,"C","","mv_par01","Layout 1","","","","","Layout 2","","","","","","","","","","","","","","","","","","","",""})


	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	dbSelectArea(_sAlias)

Return(.t.)
