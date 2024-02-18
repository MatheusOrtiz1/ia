#include "totvs.ch"

user function MT120FIM()


RETURN
/*
Programa.: MT120FIM.PRW
Tipo.....: Ponto de Entrada 
Autor....: Odair Batista - TOTVS Unidade Londrina
Data.....: 13/01/2023
Descrição: Ponto de entrada após a gravação do pedido de compras
*/


//-------------------------------------------------------------------
/*/{Protheus.doc} MT120FIM
Função principal do ponto de entrada
@author Odair Batista - TOTVS Unidade Londrina
@since 13/01/2023
@version 1.0
@type function
/*/
//-------------------------------------------------------------------
/*
	local areaDEF := getArea()
	local areaSC7 := SC7->(getArea())
	local areaDHK := DHK->(getArea())
	local areaSAL := SAL->(getArea())
	local nConf   := paramIXB[3]   //indica a ação no processo [0=Cancelada ou 1=Confirmada]
	local cEmpSCR := ""
	local cGrupo  := "" 
	local cTipCom := "006"
	local aGrupos := {}
	local nGrupo  := 0

	private oAlerts  := pfwAlerts():New()
	private cNumPC   := paramIXB[2]   //Número do pedido de compras
	private cTipoDoc := "IP"
	private cNumSCR  := padR(cNumPC, len(SCR->CR_NUM), " ")
	private aGrpItem := {}

	oAlerts:Empty()

	if nConf == 1	//Confirmado
		dbSelectArea("SC7")
		SC7->(dbSetOrder(1))		//C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
		if SC7->(dbSeek(xFilial("SC7") + cNumPC))
			//INICIO: Rotina para tratamento de exceção a regra de aprovação padrão
			cEmpSCR := upper(allTrim(superGetMV("MV_UEMPSCR", .f., "37")))

			if (INCLUI .or. ALTERA) ;
				.and. upper(allTrim(cEmpAnt)) $ cEmpSCR

				aGrupos  := {}
				aGrpItem := {}

				do while !SC7->(eof()) ;
					.and. SC7->C7_FILIAL == xFilial("SC7") ;
					.and. SC7->C7_NUM    == cNumPC 

					if !empty(SC7->C7_TIPCOM)
						cTipCom := SC7->C7_TIPCOM 
					else 
						if select("qDHK") > 0
							qDHK->(dbCloseArea())
						endIf 

						beginSql alias "qDHK"
							SELECT DHK.DHK_CODIGO 
							FROM %table:DHK% DHK 
							WHERE DHK.%notDel%
							  AND DHK.DHK_FILIAL = %xFilial:DHK%
							  AND DHK.DHK_PEDCOM = %exp:SC7->C7_ITEMCTA%
						endSql 

						dbSelectArea("qDHK")
						qDHK->(dbGoTop())
						if qDHK->(eof())
							cTipCom := "006"
						else 
							cTipCom := qDHK.DHK_CODIGO 
						endIf

						qDHK->(dbCloseArea())
					endIf

					dbSelectArea("DHK")
					DHK->(dbSetOrder(1))	//DHK_FILIAL+DHK_CODIGO
					if !DHK->(dbSeek(xFilial("DHK") + cTipCom))
						oAlerts:Add("MT120FIM:CreateSCR" ;
									, "Tipo compra não encontrado!" ;
									, "E" ;
									, "O tipo de compra [" + cTipCom + "] informado não foi encontrado. Pedido de compra [" ;
									  + SC7->C7_NUM + "] e item [" + SC7->C7_ITEM + "].")
					else
						SC7->(recLock("SC7", .f.))
						SC7->C7_CONAPRO := "B"
						SC7->C7_TIPCOM  := DHK->DHK_CODIGO
						SC7->(msUnlock())

						//INICIO: Verificação de existência de grupo de aprovação para o tipo de compra
						cGrupo := ""
 
						if select("qDHM") > 0
							qDHM->(dbCloseArea())
						endIf

						beginSql alias "qDHM"
							SELECT DHM.DHM_GRUPO
							FROM %table:DHM% DHM 
							WHERE DHM.%notDel%
							  AND DHM.DHM_FILIAL = %xFilial:DHM% 
							  AND DHM.DHM_TIPCOM = %exp:DHK->DHK_CODIGO%
						endSql 
 
						dbSelectArea("qDHM")
						qDHM->(dbGoTop())
						if !qDHM->(eof())
							cGrupo := qDHM->DHM_GRUPO
						endIf

						qDHM->(dbCloseArea())
						//FIM: Verificação de existência de grupo de aprovação para o tipo de compra

						if empty(cGrupo)
							oAlerts:Add("MT120FIM:CreateSCR" ;
										, "Grupo aprovação não informado!" ;
										, "E" ;
										, "O tipo de compra [" + DHK->DHK_CODIGO + "] informado no pedido de compra [" ;
										+ SC7->C7_NUM + "] e item [" + SC7->C7_ITEM + "] não está relacionado a um grupo " ;
										+ "de aprovação.")
						else
							dbSelectArea("SAL")
							SAL->(dbSetOrder(1))	//AL_FILIAL+AL_COD+AL_ITEM
							if !SAL->(dbSeek(xFilial("SAL") + cGrupo))
								oAlerts:Add("MT120FIM:CreateSCR" ;
											, "Grupo aprovação não encontrado!" ;
											, "E" ;
											, "O tipo de compra [" + DHK->DHK_CODIGO + "] informado no pedido de compra [" ;
											+ SC7->C7_NUM + "] e item [" + SC7->C7_ITEM + "] está relacionado ao grupo " ;
											+ "de aprovação [" + cGrupo + "] e que não foi encontrado.")
							elseIf SAL->AL_DOCIP
								//Quando for o primeiro registro limpa as aprovações SCR e DBM
								if empty(aGrupos)	
									emptyApprove()
								endIf 

								//Aglutinação por grupo para geração da SCR
								nGrupo := aScan(aGrupos, {|x| x[1] == SAL->AL_COD})
								if nGrupo == 0
									aAdd(aGrupos, {SAL->AL_COD, 0, DHK->DHK_CODIGO})
									nGrupo := aScan(aGrupos, {|x| x[1] == SAL->AL_COD})
								endIf 

								aGrupos[nGrupo, 2] += SC7->C7_TOTAL
								aAdd(aGrpItem, {aGrupos[nGrupo, 1], SC7->C7_ITEM})
							endIf
						endIf
					endIf

					SC7->(dbSkip())
				endDo 

				//Se houve agrutinação cria os registro de aprovação SCR
				if !empty(aGrupos)
					for nGrupo := 1 to len(aGrupos)
						createApprove(aGrupos[nGrupo, 1], aGrupos[nGrupo, 2], aGrupos[nGrupo, 3])
					next nGrupo
				endIf
			endIf 
			//FIM: Rotina para tratamento de exceção a regra de aprovação padrão
		endIf
	endIf

	oAlerts:Show()
	oAlerts:Destroy()

	restArea(areaSAL)
	restArea(areaDHK)
	restArea(areaSC7)
	restArea(areaDEF)
return


//-------------------------------------------------------------------

//-------------------------------------------------------------------
static function emptyApprove()
	//INICIO: Eliminação de estrutura de aprovação pré-existente para recriação
	if select("qSCR") > 0
		qSCR->(dbCloseArea())
	endIf

	beginSql alias "qSCR"
		SELECT SCR.R_E_C_N_O_ AS CR_RECNO 
		FROM %table:SCR% SCR 
		WHERE SCR.%notDel%
		  AND SCR.CR_FILIAL = %xFilial:SCR%
		  AND SCR.CR_TIPO   = %exp:cTipoDoc%
		  AND SCR.CR_NUM    = %exp:cNumSCR%
	endSql

	dbSelectArea("SCR")
	SCR->(dbSetOrder(1))	//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL

	dbSelectArea("qSCR")
	qSCR->(dbGoTop())

	do while !qSCR->(eof())
		SCR->(dbGoTo(qSCR->CR_RECNO))
		if !SCR->(eof())
			SCR->(recLock("SCR", .f.))
			SCR->(dbDelete())
			SCR->(msUnlock())
		endIf

		qSCR->(dbSkip())
	endDo 

	qSCR->(dbCloseArea())

	if select("qDBM") > 0
		qDBM->(dbCloseArea())
	endIf

	beginSql alias "qDBM"
		SELECT DBM.R_E_C_N_O_ AS DBM_RECNO 
		FROM %table:DBM% DBM
		WHERE DBM.%notDel%
		  AND DBM.DBM_FILIAL = %xFilial:DBM%
		  AND DBM.DBM_TIPO   = %exp:cTipoDoc%
		  AND DBM.DBM_NUM    = %exp:cNumSCR%
	endSql

	dbSelectArea("DBM")
	DBM->(dbSetOrder(1))	//DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USER+DBM_USEROR

	dbSelectArea("qDBM")
	qDBM->(dbGoTop())

	do while !qDBM->(eof())
		DBM->(dbGoTo(qDBM->DBM_RECNO))
		if !DBM->(eof())
			DBM->(recLock("DBM", .f.))
			DBM->(dbDelete())
			DBM->(msUnlock())
		endIf

		qDBM->(dbSkip())
	endDo 

	qDBM->(dbCloseArea())
	//FIM: Eliminação de estrutura de aprovação pré-existente para recriação
return 


//-------------------------------------------------------------------

Função para criação de registros de aprovação do pedido de compras para empresas com exceção a regra padrão

//-------------------------------------------------------------------
static function createApprove(cGrupo, nTotal, cTipCom)
	local cAuxNivel  := ""
	local nPrazo     := 0
	local nAviso     := 0
	local dPrazo     := cToD("//")
	local dAviso     := cToD("//")
	local lEscalona	 := .f.
	local lEscalonaS := .f.
	local aPerfil    := {}
	local nRow       := 0
	local nGrpItem   := 0

	default cGrupo  := ""
	default nTotal  := 0
	default cTipCom := ""

	//INICIO: Recriação de estrutura de aprovação
	if select("qSAL") > 0
		qSAL->(dbCloseArea())
	endIf

	beginSql alias "qSAL"
		SELECT SAL.*, DHL.DHL_LIMMAX
		FROM %table:SAL% SAL 
		INNER JOIN %table:DHL% DHL
		   ON DHL.%notDel%
		  AND DHL.DHL_FILIAL = %xFilial:DHL%
		  AND DHL.DHL_COD    = SAL.AL_PERFIL
		WHERE SAL.%notDel%
		  AND SAL.AL_FILIAL = %xFilial:SAL%
		  AND SAL.AL_COD    = %exp:cGrupo% 
		ORDER BY SAL.AL_NIVEL		  
	endSql 

	dbSelectArea("qSAL")
	qSAL->(dbGoTop())

	if !qSAL->(eof())
		do while !qSAL->(eof())
			if aScan(aPerfil, {|x| x == qSAL->DHL_LIMMAX}) == 0
				aAdd(aPerfil, qSAL->DHL_LIMMAX)
			endIf 

			qSAL->(dbSkip())
		endDo  

		qSAL->(dbGoTop())

		aSort(aPerfil)
		cAuxNivel := qSAL->AL_NIVEL

		dbSelectArea("DHK")
		DHK->(dbSetOrder(1))	//DHK_FILIAL+DHK_CODIGO
		if DHK->(dbSeek(xFilial("DHK") + cTipCom))
			if DHK->DHK_PRAZOP < nPrazo
				nPrazo := DHK->DHK_PRAZOP
			endIf

			if DHK->DHK_AVISOP < nAviso
				nAviso := DHK->DHK_AVISOP
			endIf

			if DHK->DHK_ESCALP .and. !lEscalona
				lEscalona := .t.
			endIf

			if DHK->DHK_ESCTPC .and. !lEscalonaS
				lEscalonaS := .t.
			endIf
		endIf 

		dPrazo := dDatabase + nPrazo
		dAviso := dPrazo - nAviso

		do while !qSAL->(eof())
			nRow := aScan(aPerfil, {|x| x == qSAL->DHL_LIMMAX})
			if nRow > 1 .and. aPerfil[(nRow - 1)] > nTotal
				qSAL->(dbSkip())
				loop
			endIf 

			SCR->(recLock("SCR", .t.))
			SCR->CR_FILIAL	:= xFilial("SCR")
			SCR->CR_NUM		:= cNumSCR
			SCR->CR_TIPO	:= cTipoDoc
			SCR->CR_NIVEL	:= qSAL->AL_NIVEL
			SCR->CR_USER	:= qSAL->AL_USER
			SCR->CR_APROV	:= qSAL->AL_APROV
			SCR->CR_STATUS	:= if(qSAL->AL_NIVEL == cAuxNivel, "02", "01")
			SCR->CR_TOTAL	:= nTotal
			SCR->CR_EMISSAO	:= dDatabase
			SCR->CR_MOEDA	:= 1
			SCR->CR_TXMOEDA	:= 1
			SCR->CR_PRAZO	:= dPrazo
			SCR->CR_AVISO	:= dAviso
			SCR->CR_ESCALON	:= lEscalona
			SCR->CR_ESCALSP	:= lEscalonaS
			SCR->CR_GRUPO   := qSAL->AL_COD
			SCR->CR_ITGRP   := "01"
			SCR->(msUnlock())

			for nGrpItem := 1 to len(aGrpItem)
				if aGrpItem[nGrpItem, 1] == SAL->AL_COD
					//Geração da tabela DBM
					DBM->(recLock("DBM", .t.))
					DBM->DBM_FILIAL	:= xFilial("DBM")
					DBM->DBM_TIPO	:= cTipoDoc
					DBM->DBM_NUM	:= cNumSCR
					DBM->DBM_ITEM   := aGrpItem[nGrpItem, 2]
					DBM->DBM_GRUPO	:= qSAL->AL_COD
					DBM->DBM_ITGRP	:= "01"
					DBM->DBM_USER	:= qSAL->AL_USER
					DBM->DBM_USAPRO	:= qSAL->AL_APROV
					DBM->DBM_APROV	:= "2"
					DBM->DBM_VALOR	:= nTotal
					DBM->DBM_TIPCOM := cTipCom
					DBM->(msUnlock())
				endIf 
			next nGrpItem 

			qSAL->(dbSkip())
		endDo 
	endIf 

	qSAL->(dbCloseArea())
	//FIM: Recriação de estrutura de aprovação
return 
