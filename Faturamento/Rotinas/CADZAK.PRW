#INCLUDE 'ap5mail.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'rwmake.ch'
#INCLUDE 'topconn.ch'
#INCLUDE 'fileio.ch'
#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"

// IMPORTACAO DE LANCAMENTOS, ARQUIVO .CSV NO FORMATO
//COD_CONTA;DATA(YYYYMMDD);VALOR_CREDITO;VALOR_DEBITO;

static oAlerts   := pfwAlerts():New()	//Instanciando a classe para controle de mensagens
static cProgram  := "CADZAK"			//Nome da função principal para chamada externa do programa
static cTitle  	 := "IMPORTACAO CSV FAT"			//Título do programa

user function CADZAK()
	local aArea := getArea()

	private oBrowse := nil

	oBrowse := fwMBrowse():New()		//Instanciando o objeto browse

	oBrowse:SetAlias("ZAK")				//Setando a tabela
	oBrowse:SetDescription(cTitle)		//Setando a descrição da rotina

	oBrowse:Activate()		//Ativação do browser

	restArea(aArea)
return

static function menuDef()
	local aRot := {}

	//Adicionando opções
	add option aRot title 'Visualizar' action 'ViewDef.' + cProgram operation 1 access 0
	add option aRot title 'Importar'    action 'U_IMPZAK()'         operation 3 access 0
//	add option aRot title 'Alterar'    action 'ViewDef.' + cProgram operation 4 access 0
	add option aRot title 'Excluir'    action 'ViewDef.' + cProgram operation 5 access 0
	add option aRot title 'Processa Registro'    action 'U_PROCZAK1' operation 5 access 0

return(aRot)

User Function PROCZAK1
	cMsg := ''
	if empty(ZAK->ZAK_PEDIDO)
		FWMsgRun(/*oComponent*/,{|| geraped() },'Aguarde','Gerando Pedido')
		DEFINE MSDIALOG oDlg TITLE "Resumo" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL
		@ 020,010 Get cMsg Size 230,100 MEMO of oDlg Pixel
		@ 128, 179 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL ACTION ODLG:END()
		ACTIVATE MSDIALOG oDlg CENTERED
	endif
return

User Function PROCZAKT
	cMsg := ''
	dbselectarea("ZAK")
	dbsetorder(1)
	dbgotop()
	while !eof()
		if empty(ZAK->ZAK_PEDIDO)
			FWMsgRun(/*oComponent*/,{|| geraped() },'Aguarde','Gerando Pedido')
		endif
		dbselectarea("ZAK")
		dbskip()
	enddo
	DEFINE MSDIALOG oDlg TITLE "Resumo" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL
	@ 020,010 Get cMsg Size 230,100 MEMO of oDlg Pixel
	@ 128, 179 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL ACTION ODLG:END()
	ACTIVATE MSDIALOG oDlg CENTERED
return

static function modelDef()
	local oModel  := nil
	local oStrZAK := fwFormStruct(1, 'ZAK')

	oModel := mpFormModel():New('MainModel', /*{|oModel| preValidDef(oModel)}*/ ;	//Pré-validação do modelo
	, {|oModel| validDef(oModel)} ;		//Validação do modelo (Equilave ao "TUDOOK")
	, {|oModel| saveDef(oModel)} ;		//Gravação da edição do registro (Commit)
	, /*{|oModel| cancelDef(oModel)}*/)	//Cancelamento da edição do registro
	oModel:SetDescription(cTitle)

	//Criação de objetos de interface
	oModel:addFields('MFieldZAK',, oStrZAK)

	//Definindo propriedades de atributos (campos) em tela
//	oStrZCA:SetProperty("ZAJ_CODSAF" , MODEL_FIELD_WHEN, {|| INCLUI})

	oModel:SetPrimaryKey({"ZAK_FILIAL", "ZAK_EMISSA","ZAK_CLIENT","ZAK_LOJA","ZAK_CLVLCA","ZAK_COND"})		//Indicando índice primário

	//Informando as descrições para os modelos de dados
	oModel:getModel('MFieldZAK'):SetDescription(cTitle)
return(oModel)

static function viewDef()
	local oView	  := nil
	local oModel  := modelDef()
	local oStrZAK := fwFormStruct(2, 'ZAK')


	oView := fwFormView():New()		//Instanciando a Viewer para interface

	oView:SetModel(oModel)			//Indicando o modelo de dados para a Viewer

	//Adicionando objetos de interface
	oView:AddField('formZAK', oStrZAK, 'MFieldZAK')

	oView:CreateHorizontalBox('boxZAK', 100)

	oView:SetOwnerView('formZAK', 'boxZAK')

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({|| .t.})

	oView:SetViewCanActivate({|oView| beforeViewAct(oView, oModel)})

return(oView)

static function beforeViewAct(oView, oModel)
	local nOpc     := oModel:GetOperation()
	Local lRet := .t.
	Local _area := getarea()
	Local _aSC5 := SC5->(getarea())

	if nOpc==5
		if !empty(ZAK->ZAK_PEDIDO)
			dbselectarea("SC5")
			dbsetorder(1)
			if dbseek(xFilial()+ZAK->ZAK_PEDIDO)
				lRet := .F.
			ENDIF
		ENDIF
	endif

	restarea(_aSC5)
	restarea(_area)
	//Se retornar falso não carrega a tela
return(lRet)

static function validDef(oModel)
	local areaZAK   := ZAK->(getArea())
	//local oModelZAK := oModel:GetModel('MFieldZAK')
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

	restArea(areaZAK)


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

User Function IMPZAK()
	Local i
	Private aDados := {}
	Private oLeTxt
	Private aCod		 := {}
	Private cPerg  	     := "CADZAK"
	Private cEOL    	 := "CHR(13)+CHR(10)"

	Private nPEmp  	 := 1
	Private nPCdReg	 := 3
	Private nPDsReg	 := 5
	Private nPMun	 := 6

	if !pergunte(cPerg,.t.)
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
			cLinha := strtran(cLinha,",",".")
			_auxIni := 1
			_auxFim := 1
			while _auxFim<=len(cLinha)
				if substr(cLinha,_auxFim,1) == ";"
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
	cMsg := ""
	lProcessa := .F.
	if msgyesno("Deseja processar os pedidos após importar?","")
		lProcessa := .T.
	endif

 	for i:=1 to len(aDados)
		_emissao := stod(alltrim(aDados[i,01]))
		_cliente := alltrim(aDados[i,02])
		_lojacli := alltrim(aDados[i,03])
		_naturez := alltrim(aDados[i,04])
		_itemcta := alltrim(aDados[i,05])
		_clvlc    := alltrim(aDados[i,06])
		_condpag := alltrim(aDados[i,07])
		_tpfrete := alltrim(aDados[i,08])
		_reciss  := alltrim(aDados[i,09])
		_estpres := alltrim(aDados[i,10])
		_munpres := alltrim(aDados[i,11])
		_fecent  := stod(alltrim(aDados[i,12]))
		_uccusto := alltrim(aDados[i,13])
		_uhist   := alltrim(aDados[i,14])
		_produto := alltrim(aDados[i,15])
		_qtdven  := val(alltrim(aDados[i,16]))
		_prcven  := val(alltrim(aDados[i,17]))
		_tes     := alltrim(aDados[i,18])
		_cc      := alltrim(aDados[i,19])
		_itemctP := alltrim(aDados[i,20])
		_clvlP   := alltrim(aDados[i,21])
		_conta   := alltrim(aDados[i,22])
		_serie   := alltrim(aDados[i,23])

		dbselectarea("SA1")
		dbsetorder(1)
		if dbseek(xFilial()+_cliente+_lojacli)
			dbselectarea("CTT")
			dbsetorder(1)
			if dbseek(xFilial()+_uccusto)
				dbselectarea("CTH")
				dbsetorder(1)
				if dbseek(xFilial()+_clvlc)
					dbselectarea("ZAK")
					dbsetorder(3)//ZAK_FILIAL+ZAK_CLIENT+ZAK_LOJA+ZAK_CC+ZAK_EMISSA+ZAK_CLVL+ZAK_COND
					if dbseek(xFilial()+SA1->A1_COD+SA1->A1_LOJA+CTT->CTT_CUSTO+DTOS(_emissao)+CTH->CTH_CLVL+SM4->M4_CODIGO)
						cMsg += " REGISTRO DUPLICADO: CLIENTE "+SA1->A1_COD+" LOJA "+SA1->A1_LOJA+" CENTRO DE CUSTO "+CTT->CTT_CUSTO+" DATA "+DTOC(_emissao)+" CLASSE VALOR "+CTH->CTH_CLVL+" COND "+SM4->M4_CODIGO+" LINHA "+cvaltochar(i)+chr(13)+chr(10)
					else
						if reclock("ZAK",.t.)
							ZAK->ZAK_FILIAL := xFilial()
							ZAK->ZAK_PEDIDO := space(6)
							ZAK->ZAK_EMISSA := _emissao
							ZAK->ZAK_DATA   := date()
							ZAK->ZAK_HORA   := time()
							ZAK->ZAK_USUARI := usrfullname(__CUSERID)
							ZAK->ZAK_LOGERR := ""
							ZAK->ZAK_SERIE  := _serie
							ZAK->ZAK_DOC    := space(9)
							ZAK->ZAK_CLIENT := SA1->A1_COD
							ZAK->ZAK_LOJA   := SA1->A1_LOJA
							ZAK->ZAK_NATURE := _naturez
							ZAK->ZAK_ITEMCC := _itemcta
							ZAK->ZAK_CLVLCA := _clvlc
							ZAK->ZAK_COND   := _condpag
							ZAK->ZAK_TPFRE  := _tpfrete
							ZAK->ZAK_RECISS := _reciss
							ZAK->ZAK_ESTPR  := _estpres
							ZAK->ZAK_MUNPRE := _munpres
							ZAK->ZAK_FECENT := _fecent
							ZAK->ZAK_CC     := CTT->CTT_CUSTO
							ZAK->ZAK_HIST   := _uhist
							ZAK->ZAK_COD    := _produto
							ZAK->ZAK_QUANT  := _qtdven
							ZAK->ZAK_PRECO  := _prcven
							ZAK->ZAK_TES    := _tes
							ZAK->ZAK_CCIT   := _cc
							ZAK->ZAK_ITEMCT := _itemctP
							ZAK->ZAK_CLVL   := _clvlp
							ZAK->ZAK_CONTA  := _conta
							msunlock()
							cMsg += "IMPORTADO: LINHA "+CVALTOCHAR(I)+CHR(13)+CHR(10)
							if lProcessa
								FWMsgRun(/*oComponent*/,{|| geraped() },'Aguarde','Gerando Pedido')
							endif
						endif
					ENDIF
				else
					cMsg += "Classe de valor nao encontrada: "+_clvlc+" linha "+cvaltochar(i)+chr(13)+chr(10)
				endif
			else
				cMsg += "Centro de custo nao encontrado: "+_uccusto+" linha "+cvaltochar(i)+chr(13)+chr(10)
			endif
		else
			cMsg += "Cliente nao encontrado: "+_cliente+" loja "+_lojacli+" linha "+cvaltochar(i)+chr(13)+chr(10)
		endif
	next

	DEFINE MSDIALOG oDlg TITLE "Resumo" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL
	@ 020,010 Get cMsg Size 230,100 MEMO of oDlg Pixel
	@ 128, 179 BUTTON oButton2 PROMPT "Fechar" SIZE 037, 012 OF oDlg PIXEL ACTION ODLG:END()
	ACTIVATE MSDIALOG oDlg CENTERED

Return

static function geraped()

	ASC5 := {}
	ASC6 := {}
	AADD(ASC5,{"C5_TIPO"	,"N"			 ,NIL})
	AADD(ASC5,{"C5_CLIENTE"	,ZAK->ZAK_CLIENT ,NIL})
	AADD(ASC5,{"C5_LOJACLI"	,ZAK->ZAK_LOJA   ,NIL})
	AADD(ASC5,{"C5_CONDPAG"	,ZAK->ZAK_COND   ,NIL})
	AADD(ASC5,{"C5_UCCUSTO"	,ZAK->ZAK_CC     ,NIL})
	AADD(ASC5,{"C5_UHIST"	,ZAK->ZAK_HIST   ,NIL})
	AADD(ASC5,{"C5_ITEMCTA"	,ZAK->ZAK_ITEMCC ,NIL})
	AADD(ASC5,{"C5_CLVL"	,ZAK->ZAK_CLVLCA   ,NIL})
	AADD(ASC5,{"C5_NATUREZ"	,ZAK->ZAK_NATURE ,NIL})
	AADD(ASC5,{"C5_TPFRETE"	,ZAK->ZAK_TPFRE  ,NIL})
	AADD(ASC5,{"C5_RECISS"	,ZAK->ZAK_RECISS   ,NIL})
	AADD(ASC5,{"C5_ESTPRES"	,ZAK->ZAK_ESTPR    ,NIL})
	AADD(ASC5,{"C5_MUNPRES"	,ZAK->ZAK_MUNPRE   ,NIL})
	AADD(ASC5,{"C5_FECENT"	,ZAK->ZAK_FECENT   ,NIL})

	AAUX := {}
	cItem := "01"
	AADD(AAUX,{"C6_ITEM"		,cItem				,NIL})
	AADD(AAUX,{"C6_PRODUTO"	,ZAK->ZAK_COD       ,NIL})
	AADD(AAUX,{"C6_QTDVEN"	,ZAK->ZAK_QUANT    ,NIL})
	AADD(AAUX,{"C6_PRCVEN"	,ZAK->ZAK_PRECO     ,NIL})
	AADD(AAUX,{"C6_TES"		,ZAK->ZAK_TES       ,NIL})
	AADD(AAUX,{"C6_QTDLIB"	,ZAK->ZAK_QUANT   ,NIL})
	AADD(AAUX,{"C6_CC"		,ZAK->ZAK_CCIT     ,NIL})
	AADD(AAUX,{"C6_ITEMCTA"		,ZAK->ZAK_ITEMCT     ,NIL})
	AADD(AAUX,{"C6_CLVL"		,ZAK->ZAK_CLVL       ,NIL})
	AADD(AAUX,{"C6_CONTA"		,ZAK->ZAK_CONTA       ,NIL})

	AADD(ASC6,ACLONE(AAUX))

	LMSERROAUTO := .f.
	LMSHELPAUTO := .T.
	MSEXECAUTO({|X,Y,Z| MATA410(X,Y,Z)},ASC5,ASC6,3)
	IF LMSERROAUTO
		CDIRLOG := "C:\TEMP\"
		CARQLOG := "LOG.TXT"
		CERROAUTO := "ERRO AO INCLUIR O PEDIDO "+CHR(13)+CHR(10)
		MOSTRAERRO(CDIRLOG, CARQLOG)
		CERROAUTO += MEMOREAD(CDIRLOG+CARQLOG)
		CERROAUTO += CHR(10)+CHR(13)
		IF RECLOCK("ZAK",.F.)
			ZAK->ZAK_LOGERR := CERROAUTO
			ZAK->ZAK_PEDIDO := "EEEEEE"
			MSUNLOCK()
		ENDIF
		FERASE(CDIRLOG+CARQLOG)
	ELSE
		DBSELECTAREA("ZAK")
		IF RECLOCK("ZAK",.F.)
			ZAK->ZAK_PEDIDO := SC5->C5_NUM
			MSUNLOCK()
			IF !EMPTY(ZAK->ZAK_SERIE)
				aRetNF := U_GERANF(SC5->C5_NUM,ZAK->ZAK_SERIE)
				if aRetNf[2]
					if reclock("ZAK",.F.)
						ZAK->ZAK_DOC      := aRetNf[1]
						msunlock()
					endif
				else
					IF RECLOCK("ZAK",.F.)
						ZAK->ZAK_LOGERR := aRetNf[1]
						ZAK->ZAK_DOC    := 'EEEEEEEEE'
						MSUNLOCK()
					ENDIF
				endif
			ENDIF
		ENDIF
	ENDIF

return
