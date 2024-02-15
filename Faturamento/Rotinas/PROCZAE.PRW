#include "protheus.ch"
#include "rwmake.ch"
#include "topConn.ch"
#include "fwMBrowse.ch"
#include "fwMVCDef.ch"

/*
PROCZAE : Processa o ZAE pra gerar pedido/nota
Autor   : Daniel Gouvea
Data    : 08/11/22
*/

User Function PROZAE43

	RPCSetType(3)
	RpcSetEnv('43','01')

	PROCZAE()

return

User Function PROZAE37

	RPCSetType(3)
	RpcSetEnv('37','01')

	PROCZAE()

return

User Function PROCZAE
	processa({|| PROCZAE()})
return

static function PROCZAE
	Local aCab   := {}
 	Local aItens := {}
	LOCAL _aFINA040 := {}
	Local _aFINA050 := {}
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	Private CTF_LOCK    := 0
	Private lSubLote    := .T.

	/*
	dbselectarea("ZAE")
	dbsetorder(3)//ZAE_FILIAL+ZAE_STATUS+ZAE_EVENTO+ZAE_ORIGEM+DTOS(ZAE_DATA)
	if dbseek(xFilial()+" ")
	*/
	IF !(ZAE->ZAE_STATUS == ' ')
		MSGINFO( "Já Processado, confira o Status!", "ATENÇÃO "+ZAE->ZAE_CHAVE )
		Return()
	ELSE
		if reclock("ZAE",.F.)
			ZAE->ZAE_STATUS := 'P'
			msunlock()
		endif

			if ZAE->ZAE_TIPO=="5" //GERA CONTAS A PAGAR E BAIXA AUTOMATICAMENTE
			FWPutSX5(,"05","DCX",'DIFERENCA DE CAIXA','DIFERENCA DE CAIXA','DIFERENCA DE CAIXA','DIFERENCA DE CAIXA')
			_cTipo := "DCX"

			_nOpcao := 3
			_cPref := "DCX"
			_cNum  := dtos(ZAE->ZAE_DATA)+" "
			_cParc := "000"
			dbselectarea("SE2")
			dbsetorder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			if dbseek(xFilial()+_cPref+_cNum)
				while !eof() .and. xFilial()+_cPref+_cNum==SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM
					_cParc := soma1(_cParc)
					dbselectarea("SE2")
					dbskip()
				enddo
			endif

			_aFINA050 := { { "E2_PREFIXO"  , _cPref             , NIL },;
				{ "E2_NUM"      , _cNum            , NIL },;
				{ "E2_TIPO"     , _cTipo              , NIL },;
				{ "E2_NATUREZ"  , ZAE->ZAE_NATURE             , NIL },;
				{ "E2_FORNECE"  , ZAE->ZAE_CLIENT            , NIL },;
				{ "E2_LOJA"  , ZAE->ZAE_LOJA            , NIL },;
				{ "E2_CCUSTO"  , ZAE->ZAE_CCUSTO, NIL },;
				{ "E2_ITEMCTA"  , ZAE->ZAE_ITEMCT, NIL },;
				{ "E2_CLVL"  , ZAE->ZAE_CLVL, NIL },;
				{ "E2_CCUSTO"  , ZAE->ZAE_CCUSTO, NIL },;
				{ "E2_CCUSTO"  , ZAE->ZAE_CCUSTO, NIL },;
				{ "E2_EMISSAO"  , ZAE->ZAE_DATA, NIL },;
				{ "E2_VENCTO"   , ZAE->ZAE_DATA, NIL },;
				{ "E2_VENCREA"  , ZAE->ZAE_DATA, NIL },;
				{ "E2_VALOR"    , ZAE->ZAE_PRECO        , NIL } }


			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, _aFINA050,, _nOpcao)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão


			If lMsErroAuto
				lMsErroAuto := .F.
				CDIRLOG := "C:\TEMP\"
				CARQLOG := "LOG.TXT"
				CERROAUTO := ""
				MOSTRAERRO(CDIRLOG, CARQLOG)
				CERROAUTO += MEMOREAD(CDIRLOG+CARQLOG)
				CERROAUTO += CHR(10)+CHR(13)
				FERASE(CDIRLOG+CARQLOG)
				IF RECLOCK("ZAE",.F.)
					ZAE->ZAE_LOGERR := CERROAUTO
					ZAE->ZAE_STATUS := 'E'
					ZAE->ZAE_DTINT := DATE()
					ZAE->ZAE_HRINT := TIME()
					MSUNLOCK()
				ENDIF
			Else
				aBaixa := {}

				Aadd(aBaixa, {"E2_FILIAL", SE2->E2_FILIAL,  nil})
				Aadd(aBaixa, {"E2_PREFIXO", SE2->E2_PREFIXO,  nil})
				Aadd(aBaixa, {"E2_NUM", SE2->E2_NUM,      nil})
				Aadd(aBaixa, {"E2_PARCELA", SE2->E2_PARCELA,  nil})
				Aadd(aBaixa, {"E2_TIPO", SE2->E2_TIPO,     nil})
				Aadd(aBaixa, {"E2_FORNECE", SE2->E2_FORNECE,  nil})
				Aadd(aBaixa, {"E2_LOJA", SE2->E2_LOJA ,    nil})
				Aadd(aBaixa, {"AUTMOTBX", "DEB",            nil})
				Aadd(aBaixa, {"AUTBANCO", ZAE->ZAE_BANCO,            nil})
				Aadd(aBaixa, {"AUTAGENCIA", ZAE->ZAE_AGENCIA,          nil})
				Aadd(aBaixa, {"AUTCONTA", ZAE->ZAE_CONTA,     nil})
				Aadd(aBaixa, {"AUTDTBAIXA", ZAE->ZAE_DATA,        nil})
				Aadd(aBaixa, {"AUTDTDEB", ZAE->ZAE_DATA,        nil})
				Aadd(aBaixa, {"AUTHIST", '',       nil})
				Aadd(aBaixa, {"AUTVLRPG", SE2->E2_VALOR,          nil})
				nSeqBx := 1
				nOpc := 3

				AcessaPerg("FINA080", .F.)
				MsExecauto({|a,b,c,d,e,f,| FINA080(a,b,c,d,e,f)}, aBaixa, nOpc, .F., nSeqBx)
				If lMsErroAuto
					lMsErroAuto := .F.
					CDIRLOG := "C:\TEMP\"
					CARQLOG := "LOG.TXT"
					CERROAUTO := ""
					MOSTRAERRO(CDIRLOG, CARQLOG)
					CERROAUTO += MEMOREAD(CDIRLOG+CARQLOG)
					CERROAUTO += CHR(10)+CHR(13)
					FERASE(CDIRLOG+CARQLOG)
					IF RECLOCK("ZAE",.F.)
						ZAE->ZAE_LOGERR := CERROAUTO
						ZAE->ZAE_STATUS := 'E'
						ZAE->ZAE_DTINT := DATE()
						ZAE->ZAE_HRINT := TIME()
						MSUNLOCK()
					ENDIF
				else
					IF RECLOCK("ZAE",.F.)
						ZAE->ZAE_STATUS := 'F'
						ZAE->ZAE_DTINT := DATE()
						ZAE->ZAE_HRINT := TIME()
						MSUNLOCK()
					ENDIF
				endif
			Endif
		elseif ZAE->ZAE_TIPO=="4" //GERA CONTAS A RECEBER E BAIXA AUTOMATICAMENTE
			FWPutSX5(,"05","DCX",'DIFERENCA DE CAIXA','DIFERENCA DE CAIXA','DIFERENCA DE CAIXA','DIFERENCA DE CAIXA')
			_cTipo := "DCX"
			_aFINA040 := {}
			_nOpcao := 3
			_cPref := "DCX"
			_cNum  := dtos(ZAE->ZAE_DATA)+" "
			_cParc := "000"
			dbselectarea("SE1")
			dbsetorder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			if dbseek(xFilial()+_cPref+_cNum)
				while !eof() .and. xFilial()+_cPref+_cNum==SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM
					_cParc := soma1(_cParc)
					dbselectarea("SE1")
					dbskip()
				enddo
			endif
			Aadd(_aFINA040,{"E1_FILIAL" 	,xFilial("SE1")							,NIL})
			Aadd(_aFINA040,{"E1_PREFIXO"    ,_cPref      					    ,NIL})
			Aadd(_aFINA040,{"E1_NUM"		,_cNum         					  		,NIL})
			Aadd(_aFINA040,{"E1_PARCELA"	,_cParc 						       		,NIL})
			Aadd(_aFINA040,{"E1_TIPO" 		,_cTipo  							        ,NIL})
			Aadd(_aFINA040,{"E1_NATUREZ"	,ZAE->ZAE_NATURE           			    	,NIL})
			Aadd(_aFINA040,{"E1_PORTADO"	,"   "      				       		,NIL})
			Aadd(_aFINA040,{"E1_CLIENTE"	,ZAE->ZAE_CLIENT      				   		,NIL})
			Aadd(_aFINA040,{"E1_LOJA"		,ZAE->ZAE_LOJA        	 			    	   	,NIL})
			Aadd(_aFINA040,{"E1_EMISSAO"	,ZAE->ZAE_DATA               				,NIL})
			Aadd(_aFINA040,{"E1_VENCTO"		,ZAE->ZAE_DATA     				,NIL})
			Aadd(_aFINA040,{"E1_VENCREA"  	,DataValida(ZAE->ZAE_DATA)  ,NIL})
			Aadd(_aFINA040,{"E1_VALOR"		,ZAE->ZAE_PRECO        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_CCUSTO"		,ZAE->ZAE_CCUSTO        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_CLVL"		,ZAE->ZAE_CLVL        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_CCD"		,ZAE->ZAE_CCDEB        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_CCC"		,ZAE->ZAE_CCCRED        		   		   	,NIL})

			MSExecAuto({|x,y| FINA040(x,y)},_aFINA040,_nOpcao)
			If lMsErroAuto
				lMsErroAuto := .F.
				CDIRLOG := "C:\TEMP\"
				CARQLOG := "LOG.TXT"
				CERROAUTO := ""
				MOSTRAERRO(CDIRLOG, CARQLOG)
				CERROAUTO += MEMOREAD(CDIRLOG+CARQLOG)
				CERROAUTO += CHR(10)+CHR(13)
				FERASE(CDIRLOG+CARQLOG)
				IF RECLOCK("ZAE",.F.)
					ZAE->ZAE_LOGERR := CERROAUTO
					ZAE->ZAE_STATUS := 'E'
					ZAE->ZAE_DTINT := DATE()
					ZAE->ZAE_HRINT := TIME()
					MSUNLOCK()
				ENDIF
			ELSE
				aBaixa := {{"E1_PREFIXO"  ,SE1->E1_PREFIXO                ,Nil    },;
					{"E1_NUM"      ,SE1->E1_NUM            ,Nil    },;
					{"E1_PARCELA"  ,SE1->E1_PARCELA                    ,Nil    },;
					{"E1_TIPO"     ,SE1->E1_TIPO                  ,Nil    },;
					{"AUTMOTBX"    ,"NOR"                  ,Nil    },;
					{"AUTBANCO"    ,ZAE->ZAE_BANCO                  ,Nil    },;
					{"AUTAGENCIA"  ,ZAE->ZAE_AGENCIA                ,Nil    },;
					{"AUTCONTA"    ,ZAE->ZAE_CONTA           ,Nil    },;
					{"AUTDTBAIXA"  ,dDataBase              ,Nil    },;
					{"AUTDTCREDITO",dDataBase              ,Nil    },;
					{"AUTHIST"     ,"BAIXA DCX"          ,Nil    },;
					{"AUTJUROS"    ,0                      ,Nil,.T.},;
					{"AUTVALREC"   ,SE1->E1_VALOR                    ,Nil    }}

				MSExecAuto({|x,y| Fina070(x,y)},aBaixa,3)
				IF lMsErroAuto
					lMsErroAuto := .F.
					CDIRLOG := "C:\TEMP\"
					CARQLOG := "LOG.TXT"
					CERROAUTO := ""
					MOSTRAERRO(CDIRLOG, CARQLOG)
					CERROAUTO += MEMOREAD(CDIRLOG+CARQLOG)
					CERROAUTO += CHR(10)+CHR(13)
					FERASE(CDIRLOG+CARQLOG)
					IF RECLOCK("ZAE",.F.)
						ZAE->ZAE_LOGERR := CERROAUTO
						ZAE->ZAE_STATUS := 'E'
						ZAE->ZAE_DTINT := DATE()
						ZAE->ZAE_HRINT := TIME()
						MSUNLOCK()
					ENDIF
				ELSE
					IF RECLOCK("ZAE",.F.)
						ZAE->ZAE_STATUS := 'F'
						ZAE->ZAE_DTINT := DATE()
						ZAE->ZAE_HRINT := TIME()
						MSUNLOCK()
					ENDIF
				ENDIF

			EndIf


		elseif ZAE->ZAE_TIPO=='3' //LANÇAMENTO CONTABIL
			cQry := " SELECT MAX(CT2_SBLOTE) AS SBLOTE FROM "+RetSqlName("CT2")
			cQry += " WHERE D_E_L_E_T_='' AND CT2_DATA='"+DTOS(DDATABASE)+"' "
			cQry += " AND CT2_LOTE='000002' "
			TCQUERY cQry NEW ALIAS "TMP1"
			dbselectarea("TMP1")
			if !eof() 	
				cSub := soma1(TMP1->SBLOTE)
			else 
				cSub := '001'
			endif 
			TMP1->(dbclosearea())

			aAdd(aCab, {'DDATALANC' ,dDataBase ,NIL} )
			aAdd(aCab, {'CLOTE' ,'000500' ,NIL} )
			aAdd(aCab, {'CSUBLOTE' ,cSub ,NIL} )
			aAdd(aCab, {'CPADRAO' ,'' ,NIL} )
//			aAdd(aCab, {'CDOC' ,'000001' ,NIL} )
			aAdd(aCab, {'NTOTINF' ,0 ,NIL} )
			aAdd(aCab, {'NTOTINFLOT' ,0 ,NIL} )
			aAdd(aItens,  {;
				{'CT2_FILIAL' , xFilial('CT2')     	, NIL},;
				{'CT2_LINHA'  , '001'             	, NIL},;
				{'CT2_MOEDLC' ,'01'                	, NIL},;
				{'CT2_DC'     ,'2'                 	, NIL},;				
				{'CT2_TPSALD' ,'1'                 	, NIL},;				
				{'CT2_CREDIT' ,ZAE->ZAE_CRED       	, NIL},;
				{'CT2_VALOR'  , ZAE->ZAE_PRECO     	, NIL},;
				{'CT2_CCC' 	  ,ZAE->ZAE_CCUSTO      , NIL},;
				{'CT2_ITEMC ' ,ZAE->ZAE_ITEMCT      , NIL},;
				{'CT2_CLVLCR' ,ZAE->ZAE_CLVL        , NIL},;
				{'CT2_HP'     ,''                  	, NIL},;
				{'CT2_CONVER' ,'15555'            	, NIL},;
				{'CT2_HIST'   ,IIF(EMPTY(ZAE->ZAE_HISTCR),'HISTORICO PADRAO',ZAE->ZAE_HISTCR) , NIL},;
				{'CT2_UINFOR' ,IIF(EMPTY(ZAE->ZAE_HISTCR),'HISTORICO PADRAO',ZAE->ZAE_HISTCR) , NIL} })
			aAdd(aItens,  {;
				{'CT2_FILIAL' , xFilial('CT2')     	, NIL},;
				{'CT2_LINHA'  , '002'             	, NIL},;
				{'CT2_MOEDLC' ,'01'                	, NIL},;
				{'CT2_DC'     ,'1'                 	, NIL},;
				{'CT2_TPSALD' ,'1'                 	, NIL},;
				{'CT2_DEBITO' ,ZAE->ZAE_DEB        	, NIL},;
				{'CT2_VALOR'  , ZAE->ZAE_PRECO     	, NIL},;
				{'CT2_CCD'    ,ZAE->ZAE_CCUSTO     	, NIL},;
				{'CT2_ITEMD ' ,ZAE->ZAE_ITEMCT      , NIL},;
				{'CT2_CLVLDB' ,ZAE->ZAE_CLVL        , NIL},;
				{'CT2_HP'     ,''                  	, NIL},;
				{'CT2_CONVER' ,'15555'            	, NIL},;
				{'CT2_HIST'   ,IIF(EMPTY(ZAE->ZAE_HISTCR),'HISTORICO PADRAO',ZAE->ZAE_HISTCR) , NIL} ,;
				{'CT2_UINFOR' ,IIF(EMPTY(ZAE->ZAE_HISTCR),'HISTORICO PADRAO',ZAE->ZAE_HISTCR) , NIL} })

			MSExecAuto({|x, y,z| CTBA102(x,y,z)}, aCab ,aItens, 3)

			If lMsErroAuto
				lMsErroAuto := .F.
				CDIRLOG := "C:\TEMP\"
				CARQLOG := "LOG.TXT"
				CERROAUTO := ""
				MOSTRAERRO(CDIRLOG, CARQLOG)
				CERROAUTO += MEMOREAD(CDIRLOG+CARQLOG)
				CERROAUTO += CHR(10)+CHR(13)
				FERASE(CDIRLOG+CARQLOG)
				IF RECLOCK("ZAE",.F.)
					ZAE->ZAE_LOGERR := CERROAUTO
					ZAE->ZAE_STATUS := 'E'
					ZAE->ZAE_DTINT := DATE()
					ZAE->ZAE_HRINT := TIME()
					MSUNLOCK()
				ENDIF
				MSGALERT( "Erro de processamento verifique o arquivo "+CDIRLOG+CARQLOG, "ERRO DE PROCESSAMENTO!" )
			ELSE
				IF RECLOCK("ZAE",.F.)
					ZAE->ZAE_STATUS := 'F'
					ZAE->ZAE_DTINT := DATE()
					ZAE->ZAE_HRINT := TIME()
					MSUNLOCK()
				ENDIF
				MSGINFO( "LANÇAMENTO CONTÁBIL GERADO COM SUCESO!", "ATENÇÃO" )
			EndIf


		elseif ZAE->ZAE_TIPO=='2' //NDC
			FWPutSX5(,"05","NDC",'NOTA DEBITO CLIENTE','NOTA DEBITO CLIENTE','NOTA DEBITO CLIENTE','NOTA DEBITO CLIENTE')
			_aFINA040 := {}
			_nOpcao := 3
			_cPref := "NDC"
			_cNum  := "0"+dtos(ZAE->ZAE_DATA)
			_cParc := "000"
			dbselectarea("SE1")
			dbsetorder(1) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			if dbseek(xFilial()+_cPref+_cNum)
				while !eof() .and. xFilial()+_cPref+_cNum==SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM
					_cParc := soma1(_cParc)
					dbselectarea("SE1")
					dbskip()
				enddo
			endif

			Aadd(_aFINA040,{"E1_FILIAL" 	,xFilial("SE1")							,NIL})
			Aadd(_aFINA040,{"E1_PREFIXO"    ,_cPref      					    ,NIL})
			Aadd(_aFINA040,{"E1_NUM"		,_cNum         					  		,NIL})
			Aadd(_aFINA040,{"E1_PARCELA"	,_cParc 						       		,NIL})
			Aadd(_aFINA040,{"E1_TIPO" 		,"NDC"  							        ,NIL})
			Aadd(_aFINA040,{"E1_NATUREZ"	,ZAE->ZAE_NATURE           			    	,NIL})
			Aadd(_aFINA040,{"E1_PORTADO"	,"   "      				       		,NIL})
			Aadd(_aFINA040,{"E1_HIST"	,IIF(EMPTY(ZAE->ZAE_HISTCR),'HISTORICO PADRAO',ZAE->ZAE_HISTCR)      		,NIL})
			Aadd(_aFINA040,{"E1_CLIENTE"	,ZAE->ZAE_CLIENT      				   		,NIL})
			Aadd(_aFINA040,{"E1_LOJA"		,ZAE->ZAE_LOJA        	 			    	   	,NIL})
			Aadd(_aFINA040,{"E1_EMISSAO"	,ZAE->ZAE_DATA               				,NIL})
			Aadd(_aFINA040,{"E1_VENCTO"		,ZAE->ZAE_DATA     				,NIL})
			Aadd(_aFINA040,{"E1_VENCREA"  	,DataValida(ZAE->ZAE_DATA)  ,NIL})
			Aadd(_aFINA040,{"E1_VALOR"		,ZAE->ZAE_PRECO        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_CCUSTO"		,ZAE->ZAE_CCUSTO        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_CLVL"		,ZAE->ZAE_CLVL        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_CCD"		,ZAE->ZAE_CCDEB        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_CCC"		,ZAE->ZAE_CCDEB        		   		   	,NIL})
			Aadd(_aFINA040,{"E1_ITEMCTA"	,ZAE->ZAE_ITEMCT        		   		   	,NIL})

			MSExecAuto({|x,y| FINA040(x,y)},_aFINA040,_nOpcao)
			If lMsErroAuto
				lMsErroAuto := .F.
				CDIRLOG := "C:\TEMP\"
				CARQLOG := "LOG.TXT"
				CERROAUTO := ""
				MOSTRAERRO(CDIRLOG, CARQLOG)
				CERROAUTO += MEMOREAD(CDIRLOG+CARQLOG)
				CERROAUTO += CHR(10)+CHR(13)
				FERASE(CDIRLOG+CARQLOG)
				IF RECLOCK("ZAE",.F.)
					ZAE->ZAE_LOGERR := CERROAUTO
					ZAE->ZAE_STATUS := 'E'
					ZAE->ZAE_DTINT := DATE()
					ZAE->ZAE_HRINT := TIME()
					MSUNLOCK()
				ENDIF
			ELSE
				IF RECLOCK("ZAE",.F.)

					ZAE->ZAE_STATUS := 'F'
					ZAE->ZAE_DTINT := DATE()
					ZAE->ZAE_HRINT := TIME()
					MSUNLOCK()
				ENDIF
			EndIf
		ELSEIF ZAE->ZAE_TIPO=='1'

			ASC5 := {}
			ASC6 := {}
			AADD(ASC5,{"C5_TIPO"	,"N"			,NIL})
			AADD(ASC5,{"C5_CLIENTE"	,ZAE->ZAE_CLIENT    ,NIL})
			AADD(ASC5,{"C5_LOJACLI"	,ZAE->ZAE_LOJA  	,NIL})
			AADD(ASC5,{"C5_CONDPAG"	,ZAE->ZAE_COND   ,NIL})
			AADD(ASC5,{"C5_UCCUSTO"	,ZAE->ZAE_CCUSTO ,NIL})
			AADD(ASC5,{"C5_UHIST"	,ZAE->ZAE_HISTCR ,NIL})
			AADD(ASC5,{"C5_ITEMCTA"	,ZAE->ZAE_ITEMCT ,NIL})
			AADD(ASC5,{"C5_CLVL"	,ZAE->ZAE_CLVL   ,NIL})
			AADD(ASC5,{"C5_NATUREZ"	,ZAE->ZAE_NATURE   ,NIL})
			AAUX := {}
			cItem := "01"
			if !empty(ZAE->ZAE_COD) .and. !empty(ZAE->ZAE_TES) .and. ZAE->ZAE_PRECO>0
				AADD(AAUX,{"C6_ITEM"		,cItem				,NIL})
				AADD(AAUX,{"C6_PRODUTO"	,ZAE->ZAE_COD       ,NIL})
				AADD(AAUX,{"C6_QTDVEN"	,1    ,NIL})
				AADD(AAUX,{"C6_PRCVEN"	,ZAE->ZAE_PRECO     ,NIL})
				AADD(AAUX,{"C6_TES"		,ZAE->ZAE_TES       ,NIL})
				AADD(AAUX,{"C6_QTDLIB"	,0   ,NIL})
				AADD(AAUX,{"C6_CC"		,ZAE->ZAE_CCUSTO     ,NIL})
				AADD(AAUX,{"C6_ITEMCTA"		,ZAE->ZAE_ITEMCT     ,NIL})
				AADD(AAUX,{"C6_CLVL"		,ZAE->ZAE_CLVL       ,NIL})				
				   
				AADD(ASC6,ACLONE(AAUX))
				cItem := soma1(cItem)
			ENDIF
			AAUX := {}

			if !empty(ZAE->ZAE_COD2) .and. !empty(ZAE->ZAE_TES2) .and. ZAE->ZAE_PRECO2>0
				AADD(AAUX,{"C6_ITEM"		,cItem				,NIL})
				AADD(AAUX,{"C6_PRODUTO"	,ZAE->ZAE_COD2       ,NIL})
				AADD(AAUX,{"C6_QTDVEN"	,1    ,NIL})
				AADD(AAUX,{"C6_PRCVEN"	,ZAE->ZAE_PRECO2     ,NIL})
				AADD(AAUX,{"C6_TES"		,ZAE->ZAE_TES2      ,NIL})
				AADD(AAUX,{"C6_QTDLIB"	,0   ,NIL})
				AADD(AAUX,{"C6_CC"		,ZAE->ZAE_CCUSTO     ,NIL})
				AADD(AAUX,{"C6_ITEMCTA"		,ZAE->ZAE_ITEMCT     ,NIL})
				AADD(AAUX,{"C6_CLVL"		,ZAE->ZAE_CLVL       ,NIL})			
				AADD(ASC6,ACLONE(AAUX))
				cItem := soma1(cItem)
			ENDIF
			AAUX := {}

			if !empty(ZAE->ZAE_COD3) .and. !empty(ZAE->ZAE_TES3) .and. ZAE->ZAE_PRECO3>0
				AADD(AAUX,{"C6_ITEM"		,cItem				,NIL})
				AADD(AAUX,{"C6_PRODUTO"	,ZAE->ZAE_COD3       ,NIL})
				AADD(AAUX,{"C6_QTDVEN"	,1    ,NIL})
				AADD(AAUX,{"C6_PRCVEN"	,ZAE->ZAE_PRECO3     ,NIL})
				AADD(AAUX,{"C6_TES"		,ZAE->ZAE_TES3       ,NIL})
				AADD(AAUX,{"C6_QTDLIB"	,0   ,NIL})
				AADD(AAUX,{"C6_CC"		,ZAE->ZAE_CCUSTO     ,NIL})
				AADD(AAUX,{"C6_ITEMCTA"		,ZAE->ZAE_ITEMCT     ,NIL})
				AADD(AAUX,{"C6_CLVL"		,ZAE->ZAE_CLVL       ,NIL})			
				AADD(ASC6,ACLONE(AAUX))
				cItem := soma1(cItem)
			ENDIF
			AAUX := {}

			if !empty(ZAE->ZAE_COD4) .and. !empty(ZAE->ZAE_TES4) .and. ZAE->ZAE_PRECO4>0
				AADD(AAUX,{"C6_ITEM"		,cItem				,NIL})
				AADD(AAUX,{"C6_PRODUTO"	,ZAE->ZAE_COD4       ,NIL})
				AADD(AAUX,{"C6_QTDVEN"	,1    ,NIL})
				AADD(AAUX,{"C6_PRCVEN"	,ZAE->ZAE_PRECO4     ,NIL})
				AADD(AAUX,{"C6_TES"		,ZAE->ZAE_TES4	       ,NIL})
				AADD(AAUX,{"C6_QTDLIB"	,0   ,NIL})
				AADD(AAUX,{"C6_CC"		,ZAE->ZAE_CCUSTO     ,NIL})
				AADD(AAUX,{"C6_ITEMCTA"		,ZAE->ZAE_ITEMCT     ,NIL})
				AADD(AAUX,{"C6_CLVL"		,ZAE->ZAE_CLVL       ,NIL})			
				AADD(ASC6,ACLONE(AAUX))
				cItem := soma1(cItem)
			ENDIF
			AAUX := {}

			IF LEN(ASC5)>0 .AND. LEN(ASC6)>0
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
					IF RECLOCK("ZAE",.F.)
						ZAE->ZAE_LOGERR := CERROAUTO
						ZAE->ZAE_STATUS := 'E'
						ZAE->ZAE_DTINT := DATE()
						ZAE->ZAE_HRINT := TIME()
						MSUNLOCK()
					ENDIF
					FERASE(CDIRLOG+CARQLOG)
				ELSE
					if reclock("ZAE",.F.)
						ZAE->ZAE_STATUS := "D"
						ZAE->ZAE_PEDIDO    := SC5->C5_NUM
						ZAE->ZAE_DTINT := DATE()
						ZAE->ZAE_HRINT := TIME()
						msunlock()
					endif
					aRetNF := U_GERANF(SC5->C5_NUM,ZAE->ZAE_SERIE)
					if aRetNf[2]
						if reclock("ZAE",.F.)
							ZAE->ZAE_STATUS := "F"
							ZAE->ZAE_NOTA      := aRetNf[1]
							ZAE->ZAE_DTINT := DATE()
							ZAE->ZAE_HRINT := TIME()
							msunlock()
						endif
					else
						IF RECLOCK("ZAE",.F.)
							ZAE->ZAE_LOGERR := aRetNf[1]
							ZAE->ZAE_STATUS := 'E'
							ZAE->ZAE_DTINT := DATE()
							ZAE->ZAE_HRINT := TIME()
							MSUNLOCK()
						ENDIF
					endif
					MsgInfo("Pedido de venda Gerado: " + SC5->C5_NUM,"PROCESSAMENTO EFETUADO COM SUCESSO!")
				ENDIF
			ELSE
				IF RECLOCK("ZAE",.F.)
					ZAE->ZAE_LOGERR := 'NAO TEM ITENS DISPONIVEIS A FATURAR'
					ZAE->ZAE_STATUS := 'E'
					ZAE->ZAE_DTINT := DATE()
					ZAE->ZAE_HRINT := TIME()
					MSUNLOCK()
				ENDIF
			ENDIF
		endif
	ENDIF

return
