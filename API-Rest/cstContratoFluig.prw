#include "totvs.ch"
#include "restFul.ch"

/*
Programa.: cstContratoFluig.prw
Tipo.....: API Rest 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 01/08/2023
Descrição: API para integração de dados com contrato Fluig
Notas....: 
*/


/*/{Protheus.doc} cstContratoFluig 
Serviço para chamada externa
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 01/08/2023
@version 1.0
@type service
/*/
WsRestFul cstContratoFluig description "API para integração de dados com contrato Fluig" Format Application_JSon 
    WsData Empresa       as string
    WsData Filial        as string
    WsData NumeroDe      as string
    WsData NumeroAte     as string
    WsData OrigemDe      as string
    WsData OrigemAte     as string
    WsData FornecedorDe  as string
    WsData FornecedorAte as string
    WsData LojaDe        as string
    WsData LojaAte       as string
    WsData DataInicioDe  as string
    WsData DataInicioAte as string
    WsData RevisaoDe     as string
    WsData RevisaoAte    as string

	WsMethod POST description "Método para inclusão" WsSyntax "/cstContratoFluig/{}"
	WsMethod PUT description "Método para alteração" WsSyntax "/cstContratoFluig/{}"
	WsMethod GET description "Método para consulta" WsSyntax "/cstContratoFluig/{Empresa, Filial, NumeroDe, NumeroAte, OrigemDe, OrigemAte, FornecedorDe, FornecedorAte, LojaDe, LojaAte, DataInicioDe, DataInicioAte, RevisaoDe, RevisaoAte}"
End WsRestFul 


/*/{Protheus.doc} POST
Método para processamento da inclusão
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 01/08/2023
@version 1.0
@type method
/*/
WsMethod POST HeaderParam HeaderAttributes WsRestFul cstContratoFluig
	local cJson     := Self:GetContent()	//Recebe os parâmetros no formato jSon
	local oParser   := nil
 	local aAlerts   := {}
    local nRow      := 0
    local oJSon     := nil
    local oContrato := nil
    local oRow      := nil
    
    private oUtils  := nil
    private oAlerts := nil

	oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    cJson := decodeUtf8(cJson)

	//Identifica cada parâmetro recebido no formato jSon
    oParser := JSonObject():new()
    if oParser == nil .or. valType(oParser:fromJson(cJson)) == "C"
		oAlerts:Add("cstContratoFluig:Post" ;
					, "Falha ao ler o JSon!" ;
					, "E" ;
					, "O JSon não foi passado corretamente para a API. Verifique!")
	else
        if empty(oParser["empresa"])
            oAlerts:Add("cstContratoFluig:Post" ;
                        , "Empresa não informada!" ;
                        , "E" ;
                        , "Não foi informada uma empresa válida. Verifique!")
        endIf 

        if empty(oParser["filial"])
            oAlerts:Add("cstContratoFluig:Post" ;
                        , "Filial não informada!" ;
                        , "E" ;
                        , "Não foi informada uma filial válida. Verifique!")
        endIf 
    endIf 

    if !oAlerts:HasErrors()
        rpcSetType(3)			                            //Informa que não haverá consumo de licenças
        rpcSetEnv(oParser["empresa"], oParser["filial"])	//Prepara ambiente para empresa 01 e filial 01

        oContrato := contratosFluig():New()
        
        oContrato:BeginRecord("insert")
        oContrato:SetValue("ZAL_FILIAL", oParser["filial"])
        oContrato:SetValue("ZAL_NUMERO", oParser["numero"])
        oContrato:SetValue("ZAL_ORIGEM", oParser["origem"])
        oContrato:SetValue("ZAL_REVISA", oParser["revisao"])
        oContrato:SetValue("ZAL_TIPREV", oParser["tipoRevisao"])
        oContrato:SetValue("ZAL_JUSTIF", oParser["justificativa"])
        oContrato:SetValue("ZAL_CC"    , oParser["centroCusto"])
        oContrato:SetValue("ZAL_SITUAC", oParser["situacao"])
        oContrato:SetValue("ZAL_SOLICI", oParser["solicitante"])
        oContrato:SetValue("ZAL_FORNEC", oParser["fornecedor"])
        oContrato:SetValue("ZAL_LOJA"  , oParser["loja"])
        oContrato:SetValue("ZAL_TIPCTR", oParser["tipoContrato"])
        oContrato:SetValue("ZAL_OBJETO", oParser["objeto"])
        oContrato:SetValue("ZAL_RESPJU", oParser["responsavelJuridico"])
        oContrato:SetValue("ZAL_REJULG", oParser["loginResponsavelJuridico"])
        oContrato:SetValue("ZAL_DTINIC", sToD(oParser["dataInicio"]))
        oContrato:SetValue("ZAL_PRAZO" , oParser["prazo"])
        oContrato:SetValue("ZAL_DTFINA", sToD(oParser["dataFinal"]))
        oContrato:SetValue("ZAL_DTASSI", sToD(oParser["dataAssinatura"]))
        oContrato:SetValue("ZAL_AVISO" , oParser["diasParaAviso"])
        oContrato:SetValue("ZAL_VALOR" , oParser["valor"])
        oContrato:SetValue("ZAL_SALDO" , oParser["saldo"])
        oContrato:EndRecord()

        for nRow := 1 to len(oParser["anexos"])
            oRow := oParser["anexos"][nRow]

            oContrato:Anexos:BeginRecord("insert")
            oContrato:Anexos:SetValue("ZAM_FILIAL", oParser["filial"])
            oContrato:Anexos:SetValue("ZAM_NUMERO", oParser["numero"])
            oContrato:Anexos:SetValue("ZAM_ORIGEM", oParser["origem"])
            oContrato:Anexos:SetValue("ZAM_REVISA", oParser["revisão"])
            oContrato:Anexos:SetValue("ZAM_NOMEOR", oRow["nomeOriginal"])
            oContrato:Anexos:SetValue("ZAM_PATHOR", oRow["caminhoOriginal"])
            oContrato:Anexos:SetValue("ZAM_IDDOCT", oRow["idDocumentoFluig"])
            oContrato:Anexos:SetValue("ZAM_NOMEAR", oRow["nomeArquivo"])
            oContrato:Anexos:SetValue("ZAM_PATHAR", oRow["caminhoArquivo"])
            oContrato:Anexos:EndRecord()
        next nRow

        oContrato:Insert()

        oAlerts:AddFrom(oContrato)
        oContrato:Destroy()

        rpcClearEnv() //volta a empresa anterior
    endIf 

    oJSon := pfwJSon():New(.f., .f., .t.)
    oJSon:AddNode()
    oJSon:AddNodeData("alerts")

    conOut("INTEGRACAO CONTRATO FLUIG ==> INICIO: " + dToC(date()) + " - " + time())
    //conOut("INTEGRACAO CONTRATO FLUIG ==> JSON --> " + cJson)

    aAlerts := oAlerts:GetAlerts()
    if !empty(aAlerts)
        for nRow := 1 to len(aAlerts)
            aAlerts[nRow, 3] := upper(allTrim(aAlerts[nRow, 3]))
            conOut("INTEGRACAO CONTRATO FLUIG ==> " + fwNoAccent(aAlerts[nRow, 1]) + " (" + fwNoAccent(aAlerts[nRow, 3]) + "): " + fwNoAccent(aAlerts[nRow, 4]))
        next nRow
    endIf

    if !oAlerts:HasErrors()
        conOut("INTEGRACAO CONTRATO FLUIG ==> REGISTRO INSERIDO COM SUCESSO!")
    endIf 

    conOut("INTEGRACAO CONTRATO FLUIG ==> FIM: " + dToC(date()) + " - " + time())

    if !oAlerts:HasErrors()
        oJSon:AddNode()
        oJSon:AddField("messageCode", "OK")
        oJSon:AddField("messageText", "Regitro inserido com sucesso!")
        oJSon:AddField("messageType", "information")
        oJSon:EndNode()
    else
        aAlerts := oAlerts:GetErrors()

        for nRow := 1 to len(aAlerts)
            aAlerts[nRow, 3] := upper(allTrim(aAlerts[nRow, 3]))

            oJSon:AddNode()
            oJSon:AddField("messageCode", aAlerts[nRow, 1])
            oJSon:AddField("messageText", aAlerts[nRow, 4])

            if aAlerts[nRow, 3] == "E"
                oJSon:AddField("messageType", "error")
            elseIf aAlerts[nRow, 3] $ "I|A"
                oJSon:AddField("messageType", "information")
            endIf 
            oJSon:EndNode()
        next nRow
    endIf 

    oJSon:EndNodeData()
    oJSon:EndNode()

    cJSon := oJSon:GetJSon()
    oJSon:Destroy()
    oUtils:Destroy()
    oAlerts:Destroy()

    Self:SetContentType("application/json; charset=utf-8")
    Self:SetResponse(cJSon)
return(.t.)


/*/{Protheus.doc} PUT
Método para processamento da alteração
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 01/08/2023
@version 1.0
@type method
/*/
WsMethod PUT HeaderParam HeaderAttributes WsRestFul cstContratoFluig
	local cJson     := Self:GetContent()	//Recebe os parâmetros no formato jSon
	local oParser   := nil
 	local aAlerts   := {}
    local nRow      := 0
    local oJSon     := nil
    local oContrato := nil
    local oRow      := nil
    local nFile     := 0
    local cFile     := ""
    local cRootPath := ""
    
    private oUtils  := nil
    private oAlerts := nil

	oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    cJson := decodeUtf8(cJson)

    oParser := JSonObject():new()
    if oParser == nil .or. valType(oParser:fromJson(cJson)) == "C"
		oAlerts:Add("cstContratoFluig:Post" ;
					, "Falha ao ler o JSon!" ;
					, "E" ;
					, "O JSon não foi passado corretamente para a API. Verifique!")
	else
        if empty(oParser["empresa"])
            oAlerts:Add("cstContratoFluig:Post" ;
                        , "Empresa não informada!" ;
                        , "E" ;
                        , "Não foi informada uma empresa válida. Verifique!")
        endIf 

        if empty(oParser["filial"])
            oAlerts:Add("cstContratoFluig:Post" ;
                        , "Filial não informada!" ;
                        , "E" ;
                        , "Não foi informada uma filial válida. Verifique!")
        endIf 
    endIf 

    if !oAlerts:HasErrors()
        rpcSetType(3)			                            //Informa que não haverá consumo de licenças
        rpcSetEnv(oParser["empresa"], oParser["filial"])	//Prepara ambiente para empresa 01 e filial 01

        oContrato := contratosFluig():New()
        oContrato:LoadAttach := .f.     //Não carrega os anexos do cadastro
        oContrato:Find(oParser["filial"], oParser["numero"], oParser["origem"], oParser["revisao"])
        oAlerts:AddFrom(oContrato)
    endIf 

    if !oAlerts:HasErrors()
        oContrato:BeginRecord("update")
        oContrato:SetValue("ZAL_JUSTIF", oParser["justificativa"])
        oContrato:SetValue("ZAL_CC"    , oParser["centroCusto"])
        oContrato:SetValue("ZAL_SITUAC", oParser["situacao"])
        oContrato:SetValue("ZAL_SOLICI", oParser["solicitante"])
        oContrato:SetValue("ZAL_FORNEC", oParser["fornecedor"])
        oContrato:SetValue("ZAL_LOJA"  , oParser["loja"])
        oContrato:SetValue("ZAL_TIPCTR", oParser["tipoContrato"])
        oContrato:SetValue("ZAL_OBJETO", oParser["objeto"])
        oContrato:SetValue("ZAL_RESPJU", oParser["responsavelJuridico"])
        oContrato:SetValue("ZAL_REJULG", oParser["loginResponsavelJuridico"])
        oContrato:SetValue("ZAL_DTINIC", sToD(oParser["dataInicio"]))
        oContrato:SetValue("ZAL_PRAZO" , oParser["prazo"])
        oContrato:SetValue("ZAL_DTFINA", sToD(oParser["dataFinal"]))
        oContrato:SetValue("ZAL_DTASSI", sToD(oParser["dataAssinatura"]))
        oContrato:SetValue("ZAL_AVISO" , oParser["diasParaAviso"])
        oContrato:SetValue("ZAL_VALOR" , oParser["valor"])
        oContrato:SetValue("ZAL_SALDO" , oParser["saldo"])
        oContrato:EndRecord()

        cRootPath := oUtils:CheckPath(getSrvProfString("ROOTPATH", ""))

        for nRow := 1 to len(oParser["anexos"])
            oRow := oParser["anexos"][nRow]

            oContrato:Anexos:Find(oRow["nomeOriginal"], oRow["caminhoOriginal"], oRow["idDocumentoFluig"])
            if !oContrato:Anexos:Available 
                //INICIO: Rotina para conversão do conteúdo base64 e geração do arquivo físico no servidor
                cFile := allTrim(oRow["caminhoArquivo"])
                if empty(cFile)
                    cFile := superGetMv("MV_UPTHANX", .f., "resources\contratosAnexos\")
                endIf
                oRow["caminhoArquivo"] := cFile

                if empty(allTrim(oRow["nomeArquivo"]))
                    oRow["nomeArquivo"] := allTrim(cEmpAnt) ;
                                        + "." + allTrim(cFilAnt) ;
                                        + "." + strZero(val(oParser["fornecedor"]), 9) + strZero(val(oParser["loja"]), 3) ;
									    + "." + subStr(allTrim(oRow["nomeOriginal"]), 7, len(allTrim(oRow["nomeOriginal"])))
                endIf

                if !empty(cFile)
                    cFile := oUtils:CheckPath(cFile)
                endIf 

                if !existDir(cFile)
                    oUtils:MakeDirectory(cFile, .t.)
                endIf

                cFile += allTrim(oRow["nomeArquivo"])

                nFile := fcreate(cFile)
                fWrite(nFile, decode64(oRow['conteudo']))
                fclose(nFile)
                //FIM: Rotina para conversão do conteúdo base64 e geração do arquivo físico no servidor

                oContrato:Anexos:BeginRecord("insert")
                oContrato:Anexos:SetValue("ZAM_FILIAL", oParser["filial"])
                oContrato:Anexos:SetValue("ZAM_NUMERO", oParser["numero"])
                oContrato:Anexos:SetValue("ZAM_ORIGEM", oParser["origem"])
                oContrato:Anexos:SetValue("ZAM_REVISA", oParser["revisao"])
                oContrato:Anexos:SetValue("ZAM_NOMEOR", oRow["nomeOriginal"])
                oContrato:Anexos:SetValue("ZAM_PATHOR", oRow["caminhoOriginal"])
                oContrato:Anexos:SetValue("ZAM_IDDOCT", oRow["idDocumentoFluig"])
                oContrato:Anexos:SetValue("ZAM_NOMEAR", oRow["nomeArquivo"])
                oContrato:Anexos:SetValue("ZAM_PATHAR", oRow["caminhoArquivo"])
                oContrato:Anexos:EndRecord()
                //FIM: Rotina para conversão do conteúdo e geração do arquivo físico no servidor
            endIf 
        next nRow

        oContrato:Update()

        oAlerts:AddFrom(oContrato)
        oContrato:Destroy()
    endIf 

    rpcClearEnv() //volta a empresa anterior

    oJSon := pfwJSon():New(.f., .f., .t.)
    oJSon:AddNode()
    oJSon:AddNodeData("alerts")

    conOut("INTEGRACAO CONTRATO FLUIG ==> INICIO: " + dToC(date()) + " - " + time())
    //conOut("INTEGRACAO CONTRATO FLUIG ==> JSON --> " + cJson)

    aAlerts := oAlerts:GetAlerts()
    if !empty(aAlerts)
        for nRow := 1 to len(aAlerts)
            aAlerts[nRow, 3] := upper(allTrim(aAlerts[nRow, 3]))
            conOut("INTEGRACAO CONTRATO FLUIG ==> " + fwNoAccent(aAlerts[nRow, 1]) + " (" + fwNoAccent(aAlerts[nRow, 3]) + "): " + fwNoAccent(aAlerts[nRow, 4]))
        next nRow
    endIf

    if !oAlerts:HasErrors()
        conOut("INTEGRACAO CONTRATO FLUIG ==> REGISTRO ALTERADO COM SUCESSO!")
    endIf 

    conOut("INTEGRACAO CONTRATO FLUIG ==> FIM: " + dToC(date()) + " - " + time())

    if !oAlerts:HasErrors()
        oJSon:AddNode()
        oJSon:AddField("messageCode", "OK")
        oJSon:AddField("messageText", "Regitro alterado com sucesso!")
        oJSon:AddField("messageType", "information")
        oJSon:EndNode()
    else
        aAlerts := oAlerts:GetErrors()

        for nRow := 1 to len(aAlerts)
            aAlerts[nRow, 3] := upper(allTrim(aAlerts[nRow, 3]))

            oJSon:AddNode()
            oJSon:AddField("messageCode", aAlerts[nRow, 1])
            oJSon:AddField("messageText", aAlerts[nRow, 4])

            if aAlerts[nRow, 3] == "E"
                oJSon:AddField("messageType", "error")
            elseIf aAlerts[nRow, 3] $ "I|A"
                oJSon:AddField("messageType", "information")
            endIf 
            oJSon:EndNode()
        next nRow
    endIf 

    oJSon:EndNodeData()
    oJSon:EndNode()

    cJSon := oJSon:GetJSon()
    oJSon:Destroy()
    oUtils:Destroy()
    oAlerts:Destroy()

    Self:SetContentType("application/json; charset=utf-8")
    Self:SetResponse(cJSon)
return(.t.)


/*/{Protheus.doc} GET
Método para processamento da consulta
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 01/08/2023
@version 1.0
@type method
@param Empresa      , string, código da empresa
@param Filial       , string, código da filial
@param NumeroDe     , string, número inicial do contrato 
@param NumeroAte    , string, número final do contrato
@param OrigemDe     , string, origem inicial do contrato
@param OrigemAte    , string, origem final do contrato
@param FornecedorDe , string, fornecedor inicial do contrato
@param FornecedorAte, string, fornecedor final do contrato
@param LojaDe       , string, loja inicial do fornecedor do contrato
@param LojaAte      , string, loja final do fornecedor do contrato
@param DataInicioDe , string, data de inicio inicial do contrato (AAAAMMDD)
@param DataInicioAte, string, data de inicio final do contrato (AAAAMMDD)
@param RevisaoDe    , string, revisão inicial do contrato
@param RevisaoAte   , string, revisão final do contrato
/*/
WsMethod GET WSReceive Empresa, Filial, NumeroDe, NumeroAte, OrigemDe, OrigemAte, FornecedorDe, FornecedorAte, LojaDe, LojaAte, DataInicioDe, DataInicioAte, RevisaoDe, RevisaoAte WsService cstContratoFluig
    local oAlerts   := nil
 	local aAlerts   := {}
	local cJSon     := ""
    local oJSon     := nil
    local oUtils    := nil
    local nRow      := 0
    local cWhere    := ""
    local cZAL      := getNextAlias()
    local cZAM      := getNextAlias()
    local aSituacao := {}
    local cSituacao := ""

	default Self:Empresa := "01"
	default Self:Filial  := "01"

	rpcSetType(3)			                //Informa que não haverá consumo de licenças
	rpcSetEnv(Self:Empresa, Self:Filial)	//Prepara ambiente para empresa 01 e filial 01

	aAdd(aSituacao, {"01", "Cancelado"})
	aAdd(aSituacao, {"02", "Em Elaboração"})
	aAdd(aSituacao, {"03", "Emitido"})
	aAdd(aSituacao, {"04", "Em Aprovação"})
	aAdd(aSituacao, {"05", "Vigente"})
	aAdd(aSituacao, {"06", "Paralisado"})
	aAdd(aSituacao, {"07", "Solicitado Finalização"})
	aAdd(aSituacao, {"08", "Finalizado"})
	aAdd(aSituacao, {"09", "Em Revisão"})
	aAdd(aSituacao, {"10", "Revisado"})
	aAdd(aSituacao, {"A ", "Revisão Aprovação p/ Alçadas"}) 

    oUtils  := pfwUtils():New()
	oAlerts := pfwAlerts():New()
	oAlerts:Empty()

    cWhere := "%"
    
    if Self:NumeroDe != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_NUMERO)) >= '" + Self:NumeroDe + "' "
    endIf 

    if Self:NumeroAte != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_NUMERO)) <= '" + Self:NumeroAte + "' "
    endIf

    if Self:OrigemDe != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_ORIGEM)) >= '" + Self:OrigemDe + "' "
    endIf 

    if Self:OrigemAte != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_ORIGEM)) <= '" + Self:OrigemAte + "' "
    endIf 

    if Self:FornecedorDe != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_FORNEC)) >= '" + Self:FornecedorDe + "' "
    endIf 

    if Self:FornecedorAte != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_FORNEC)) <= '" + Self:FornecedorAte + "' "
    endIf 

    if Self:LojaDe != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_LOJA)) >= '" + Self:LojaDe + "' "
    endIf 

    if Self:LojaAte != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_LOJA)) <= '" + Self:LojaAte + "' "
    endIf 

    if Self:DataInicioDe != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "ZAL.ZAL_DTINIC >= '" + Self:DataInicioDe + "' "
    endIf 

    if Self:DataInicioAte != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "ZAL.ZAL_DTINIC <= '" + Self:DataInicioAte + "' "
    endIf 

    if Self:RevisaoDe != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_REVISA)) >= '" + Self:RevisaoDe + "' "
    endIf 

    if Self:RevisaoAte != nil
        cWhere += if(cWhere == "%", "", "AND ")
        cWhere += "LTRIM(RTRIM(ZAL.ZAL_REVISA)) <= '" + Self:RevisaoAte + "' "
    endIf 

    if cWhere == "%"
        cWhere += " ZAL.ZAL_NUMERO = ZAL.ZAL_NUMERO "
    endIf

    cWhere += "%"

    if select(cZAL) > 0
        (cZAL)->(dbCloseArea())
    endIf

    beginSql alias cZAL
        SELECT ZAL.*
            , ISNULL(CAST(CAST(ZAL_JUSTIF AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS ZAL_JUSTIF_MEMO
            , ISNULL(CAST(CAST(ZAL_OBJETO AS VARBINARY(8000)) AS VARCHAR(8000)), '') AS ZAL_OBJETO_MEMO
            , CTT.CTT_DESC01, CTT.CTT_CLASSE
            , CN1.CN1_DESCRI
            , SA2.A2_NOME, SA2.A2_CGC, SA2.A2_END, SA2.A2_CEP, SA2.A2_BAIRRO, SA2.A2_MUN, SA2.A2_EST
        FROM %table:ZAL% ZAL
        INNER JOIN %table:CTT% CTT 
           ON CTT.%notDel%
          AND CTT.CTT_FILIAL = %xFilial:CTT%
          AND CTT.CTT_CUSTO  = ZAL.ZAL_CC
        INNER JOIN %table:CN1% CN1
           ON CN1.%notDel%
          AND CN1.CN1_FILIAL = %xFilial:CN1%
          AND CN1.CN1_CODIGO = ZAL.ZAL_TIPCTR
        INNER JOIN %table:SA2% SA2
           ON SA2.%notDel%
          AND SA2.A2_FILIAL = %xFilial:SA2%
          AND SA2.A2_COD    = ZAL.ZAL_FORNEC
          AND SA2.A2_LOJA   = ZAL.ZAL_LOJA
        WHERE ZAL.%notDel%
          AND ZAL.ZAL_FILIAL = %xFilial:ZAL%
          AND %exp:cWhere%
        ORDER BY ZAL.ZAL_NUMERO, ZAL.ZAL_ORIGEM, ZAL.ZAL_REVISA
    endSql

    dbSelectArea(cZAL)
    (cZAL)->(dbGoTop())

    if (cZAL)->(eof())
        oAlerts:Add('cstContratoFluig:Get' ;
                    , 'Registros não encontrados!' ;
                    , 'E' ;
                    , 'Não foram encontrados dados para a consulta.')
    else
        oJSon := pfwJSon():New(.f., .f., .t.,,, .t.)
        oJSon:AddNode()
        oJSon:AddNodeData('contratos')

        cSituacao := ""
        nRow      := aScan(aSituacao, {|x| allTrim(x[1]) == allTrim((cZAL)->ZAL_SITUAC)})
        if nRow > 0
            cSituacao := aSituacao[nRow, 2]
        endIf

        do while !(cZAL)->(eof())
            oJSon:AddNode()
            oJSon:AddField("empresa"                 , Self:Empresa)
            oJSon:AddField("filial"                  , (cZAL)->ZAL_FILIAL)
            oJSon:AddField("numero"                  , (cZAL)->ZAL_NUMERO) 
            oJSon:AddField("origem"                  , (cZAL)->ZAL_ORIGEM) 
            oJSon:AddField("revisao"                 , (cZAL)->ZAL_REVISA)
            oJSon:AddField("tipoRevisao"             , (cZAL)->ZAL_TIPREV)
            oJSon:AddField("descricaoTipoRevisao"    , U_CNT6001A((cZAL)->ZAL_TIPREV))
            oJSon:AddField("justificativa"           , (cZAL)->ZAL_JUSTIF_MEMO)
            oJSon:AddField("centroCusto"             , (cZAL)->ZAL_CC) 
            oJSon:AddField("descricaoCentroCusto"    , (cZAL)->CTT_DESC01) 
            oJSon:AddField("classeCentroCusto"       , (cZAL)->CTT_CLASSE) 
            oJSon:AddField("situacao"                , (cZAL)->ZAL_SITUAC) 
            oJSon:AddField("descricaoSituacao"       , cSituacao) 
            oJSon:AddField("solicitante"             , (cZAL)->ZAL_SOLICI) 
            oJSon:AddField("fornecedor"              , (cZAL)->ZAL_FORNEC) 
            oJSon:AddField("loja"                    , (cZAL)->ZAL_LOJA)
            oJSon:AddField("nome"                    , (cZAL)->A2_NOME)
            oJSon:AddField("cnpj"                    , (cZAL)->A2_CGC)
            oJSon:AddField("endereco"                , (cZAL)->A2_END)
            oJSon:AddField("bairro"                  , (cZAL)->A2_BAIRRO)
            oJSon:AddField("cep"                     , (cZAL)->A2_CEP)
            oJSon:AddField("cidade"                  , (cZAL)->A2_MUN)
            oJSon:AddField("estado"                  , (cZAL)->A2_EST)
            oJSon:AddField("tipoContrato"            , (cZAL)->ZAL_TIPCTR) 
            oJSon:AddField("descricaoTipoContrato"   , (cZAL)->CN1_DESCRI) 
            oJSon:AddField("objeto"                  , (cZAL)->ZAL_OBJETO_MEMO) 
            oJSon:AddField("responsavelJuridico"     , (cZAL)->ZAL_RESPJU) 
            oJSon:AddField("loginResponsavelJuridico", (cZAL)->ZAL_REJULG) 
            oJSon:AddField("dataInicio"              , (cZAL)->ZAL_DTINIC) 
            oJSon:AddField("prazo"                   , (cZAL)->ZAL_PRAZO) 
            oJSon:AddField("dataFinal"               , (cZAL)->ZAL_DTFINA) 
            oJSon:AddField("dataAssinatura"          , (cZAL)->ZAL_DTASSI) 
            oJSon:AddField("diasParaAviso"           , (cZAL)->ZAL_AVISO)
            oJSon:AddField("valor"                   , (cZAL)->ZAL_VALOR)
            oJSon:AddField("saldo"                   , (cZAL)->ZAL_SALDO)

            //INICIO: Obtem anexos
            if select(cZAM) > 0
                (cZAM)->(dbCloseArea())
            endIf

            beginSql alias cZAM 
                SELECT ZAM.*
                FROM %table:ZAM% ZAM
                WHERE ZAM.%notDel%
                  AND ZAM.ZAM_FILIAL = %exp:(cZAL)->ZAL_FILIAL%
                  AND ZAM.ZAM_NUMERO = %exp:(cZAL)->ZAL_NUMERO%
                  AND ZAM.ZAM_ORIGEM = %exp:(cZAL)->ZAL_ORIGEM%
            endSql 

            dbSelectArea(cZAM)
            (cZAM)->(dbGoTop())

            if !(cZAM)->(eof())
                oJSon:AddNodeData('anexos')

                do while !(cZAM)->(eof())
                    oJSon:AddNode()
                    oJSon:AddField("nomeOriginal"    , (cZAM)->ZAM_NOMEOR)
                    oJSon:AddField("caminhoOriginal" , (cZAM)->ZAM_PATHOR)
                    oJSon:AddField("idDocumentoFluig", (cZAM)->ZAM_IDDOCT)
                    oJSon:AddField("nomeArquivo"     , (cZAM)->ZAM_NOMEAR)
                    oJSon:AddField("caminhoArquivo"  , (cZAM)->ZAM_PATHAR)
                    oJSon:EndNode()

                    (cZAM)->(dbSkip())
                end 

                oJSon:EndNodeData()
            endIf 

            (cZAM)->(dbCloseArea())
            //FIM: Obtem anexos

            oJSon:EndNode()

            (cZAL)->(dbSkip())
        endDo

        oJSon:EndNodeData()
        oJSon:EndNode()

        cJSon := oJSon:GetJSon()
        oJSon:Destroy()
    endIf

    if select(cZAL) > 0
        (cZAL)->(dbCloseArea())
    endIf

	if oAlerts:HasErrors()
		aAlerts := oAlerts:GetErrors()

        oJSon := pfwJSon():New(.f., .f., .t.)
        oJSon:AddNode()
        oJSon:AddNodeData('alerts')

        for nRow := 1 to len(aAlerts)
            aAlerts[nRow, 3] := upper(allTrim(aAlerts[nRow, 3]))

            oJSon:AddNode()
            oJSon:AddField("messageCode", aAlerts[nRow, 1])
            oJSon:AddField("messageText", aAlerts[nRow, 4])

            if aAlerts[nRow, 3] == 'E'
                oJSon:AddField("messageType", "error")
            elseIf aAlerts[nRow, 3] $ 'I|A'
                oJSon:AddField("messageType", "information")
            endIf 
            oJSon:EndNode()
        next nRow

        oJSon:EndNodeData()
        oJSon:EndNode()

        cJSon := oJSon:GetJSon()
        oJSon:Destroy()
	endIf       

    oUtils:Destroy()
    oAlerts:Destroy()

    rpcClearEnv() //volta a empresa anterior

    Self:SetContentType("application/json; charset=utf-8")
    Self:SetResponse(cJSon)
return(.t.)
