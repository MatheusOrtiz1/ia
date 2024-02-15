#include "totvs.ch"
#include "fileio.ch"

/*
Programa.: CNT6002.PRW
Tipo.....: Funções 
Autor....: Odair Batista - TOTVS Unidade Londrina
Data.....: 25/10/2023
Descrição: Função para envio de arquivo da base de conhecimento para o GED do Fluig
Notas....: Utilizado na gravação do banco de conhecimento
*/


/*/{Protheus.doc} CNT6002
Função principal para chamada externa
@author Odair Batista - TOTVS Unidade Londrina
@type Function
@since 25/10/2023
@version 1.0
@param nOpc   , number, opção da ação  (1=Inclusão, 2=Alteração, 3=Exclusão)
@param cObjeto, string, código do objeto
@param nFolder, number, código da pasta no fluig 
@return, array, mensagens de processamento
/*/
user function CNT6002(nOpc, cObjeto, nFolder)
    local areaDEF   := getArea()
    local areaACB   := ACB->(getArea())
    local areaZCB   := ZCB->(getArea())
    local cDirDoc   := superGetMv("MV_DIRDOC", .f., "\DIRDOC\")
    local cFile     := ""
    local cPath     := ""
    //local aFolders  := {}
    local cDoctoId  := ""
    local aAlerts   := {}

    default nOpc    := 1    //Inclusão
    default cObjeto := ""
    default nFolder := 0

    //Integração somente para contratos
    if funName() != "CNTA300"
        return(.t.)
    endIf 

    private oAlerts := pfwAlerts():New()
    private oUtils  := pfwUtils():New()

    oAlerts:Empty()

    //Se for passado um objeto faz a busca, caso contrário verifica se já está posicionado.
    if !empty(cObjeto)
        dbSelectArea("ACB")
        ACB->(dbSetOrder(1))    //ACB_FILIAL + ACB_CODOBJ
        ACB->(dbSeek(xFilial("ACB") + cObjeto))
    endIf 

    if ACB->(eof())
        oAlerts:Add("CNT6002:Fluig", ;
                    "Objeto não posicionado!", ;
                    "E", ;
                    "O objeto do banco de conhecimento não foi posicionado. Verifique!")
    else 
        dbSelectArea("ZCB")
        ZCB->(dbSetOrder(1))    //ZCB_FILIAL+ZCB_CODOBJ
        if !ZCB->(dbSeek(xFilial("ZCB") + ACB->ACB_CODOBJ))
            ZCB->(recLock("ZCB", .t.))
            ZCB->ZCB_FILIAL := xFilial("ZCB")
            ZCB->ZCB_CODOBJ := ACB->ACB_CODOBJ
            ZCB->(msUnlock())
        endIf 

        cFile := allTrim(ACB->ACB_OBJETO)
        cPath := oUtils:CheckPath(cDirDoc)
        cPath += "co" + cEmpAnt + "\shared\"

        if !existDir(cPath) 
            oAlerts:Add("CNT6002:Fluig", ;
                        "Diretório de documentos não existe!", ;
                        "E", ;
                        "Não foi encontrado o diretório dos documentos do banco de conhecimento [" + cPath + "] para " ;
                        + "a empresa [" + cEmpAnt + "]")
        elseIf nOpc != 3 .and. !file(cPath + cFile)
            oAlerts:Add("CNT6002:Fluig", ;
                        "Documento não existe!", ;
                        "E", ;
                        "Não foi encontrado o arquivo do documento [" + cFile + "] no banco de conhecimento com caminho [" + cPath + "] para " ;
                        + "a empresa [" + cEmpAnt + "]")
        endIf 

        if !oAlerts:HasErrors() 
            if nOpc == 3    //Exclusão
                if !empty(ZCB->ZCB_DOCFLG)
                    processa({|| fluigDelete(val(ZCB->ZCB_DOCFLG))})    //Eliminar anexo do Fluig (GED)

                    if !oAlerts:HasErrors() 
                        ZCB->(recLock("ZCB", .f.))
                        ZCB->ZCB_DOCFLG := "" 
                        ZCB->(msUnlock())
                    endIf 
                endIf 
            else            //Inclusão ou Alteração
                /*
                if empty(nFolder)
                    //Obtem as pastas do Fluig
                    //processa({|| aFolders := foldersFromFluig()})
                
                    //Verifica se existe a pasta especifica da empresa para anexos
                    //nFolder := aScan(aFolders, {|x| subStr(allTrim(x[2]), 1, 5) == cEmpAnt + " - "})

                    //Obtem a pasta do Fluig padrão do parâmetro de sistema da empresa
                    nFolder := superGetMv("MV_UFLGFLD", .f., 0)
                endIf 
                */

                if nFolder == 0
                    oAlerts:Add("CNT6002:Fluig", ;
                                "Pasta no Fluig não informada!", ;
                                "E", ;
                                "Não foi informado a pasta da empresa [" + cEmpAnt + "] do Fluig para anexar o arquivo [" ;
                                + cFile + "].")
                else
                    /*
                    if !empty(ZCB->ZCB_DOCFLG)
                        processa({|| fluigUpdate(cPath, cFile, nFolder, val(ZCB->ZCB_DOCFLG))})    //Atualizar anexo ao Fluig (GED)
                    else
                    */
                    if empty(ZCB->ZCB_DOCFLG)
                        //processa({|| cDoctoId := fluigInsert(cPath, cFile, aFolders[nFolder, 1])})    //Inserir anexo ao Fluig (GED)
                        processa({|| cDoctoId := fluigInsert(cPath, cFile, nFolder)})    //Inserir anexo ao Fluig (GED)

                        if empty(cDoctoId)
                            oAlerts:Add("CNT6002:Fluig", ;
                                        "Documento no Fluig não foi anexado!", ;
                                        "E", ;
                                        "Não foi anexado ao GED do Fluig na pasta da empresa [" + cEmpAnt ;
                                        + "] o arquivo [" + cFile + "].")
                        else
                            ZCB->(recLock("ZCB", .f.))
                            ZCB->ZCB_DOCFLG := cDoctoId 
                            ZCB->(msUnlock())
                        endIf
                    endIf 
                endIf 
            endIf 
        endIf        
    endIf

    oUtils:Destroy()

    aAlerts := oAlerts:GetAlerts()
    oAlerts:Destroy()

    restArea(areaZCB)
    restArea(areaACB)
    restArea(areaDEF)
return(aAlerts)


/*/{Protheus.doc} foldersFromFluig
Função para obter as pastas existentes no Fluig
@author Odair Batista - TOTVS Unidade Londrina
@type Function
@since 26/10/2023
@version 1.0
/*/
static function foldersFromFluig()
    local aFolders  := {}
	local cEndPoint := superGetMv("MV_UFLGHOS", .f., "http://fluig.conasa.com:8072/")
	local cUser     := superGetMv("MV_UFLGUSR", .f., "integrator")
	local cPasswd   := superGetMv("MV_UFLGPWD", .f., "super")
    local cXML      := ""
    local oFluig    := nil
    local cResults  := ""
	local cMessage  := ''
	local cError    := ''
    local oResults  := nil
    local aValues   := {}
    local nValue    := 0
    local isUnique  := .f.

	procRegua(0)
	incProc("Consultando...")

    cXML := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.dataservice.ecm.technology.totvs.com/">'
    cXML += '<soapenv:Header/>'
    cXML += '<soapenv:Body>'
    cXML += '  <ws:getDataset>'
    cXML += '    <companyId>1</companyId>'
    cXML += '    <username>' + cUser + '</username>'
    cXML += '    <password>' + cPasswd + '</password>'
    cXML += '    <name>dsFoldersGet</name>'
    cXML += '    <fields/>'
    cXML += '    <constraints/>'
    cXML += '    <order/>'
    cXML += '  </ws:getDataset>'
    cXML += '</soapenv:Body>'
    cXML += '</soapenv:Envelope>'

    cEndPoint += if(subStr(cEndPoint, len(cEndPoint), 1) == "/", "", "/")
	cEndPoint += 'webdesk/ECMDatasetService?wsdl'

	oFluig := tWsdlManager():New()
	oFluig:lVerbose := .t.
	oFluig:nTimeout := 120
	oFluig:lSSLInsecure := .t.
	oFluig:bNoCheckPeerCert := .t.

	oFluig:AddHttpHeader("Accept-Encoding", "gzip,deflate")
	oFluig:AddHttpHeader("Content-Type", "text/xml;charset=UTF-8")
	oFluig:AddHttpHeader("Connection", "Keep-Alive")
	oFluig:AddHttpHeader("Content-Length", cValToChar(len(cXML)))
	oFluig:AddHttpHeader("Access-Control-Allow-Origin", "*")

    if !oFluig:ParseURL(cEndPoint)
        oAlerts:Add('CNT6002:Fluig', ;
                    'Processo não inicializado!', ;
                    'E', ;
                    'Não foi possível comunicação com o serviço Fluig.' + CRLF + allTrim(oFluig:cError))
    else
        if !oFluig:SetOperation('getDataset')
            oAlerts:Add('CNT6002:Fluig', ;
                        'Processo não inicializado!', ;
                        'E', ;
                        'Não foi possível requisitar o operador do serviço Fluig.' + CRLF + allTrim(oFluig:cError))
        else
            if !oFluig:SendSoapMsg(cXML)
                oAlerts:Add('CNT6002:Fluig', ;
                            'Processo não inicializado!', ;
                            'E', ;
                            'Não foi possível enviar requisição ao serviço Fluig.' + CRLF + allTrim(oFluig:cError))
            else
                //Trata o retorno da alteração do formulário para obter a nova versão gerada
                cResults := oFluig:GetSoapResponse()
                oResults := xmlParser(cResults, "_", @cMessage, @cError)
                if valType(oResults) != "O"
                    oAlerts:Add('CNT6002:Fluig', ;
                                'Processo sem retorno valido!', ;
                                'E', ;
                                'Não houve um retorno valido da requisição ao serviço Fluig.' ;
                                + CRLF + 'Aviso: [' + allTrim(cMessage) + CRLF + 'Erro:' + allTrim(cError)) 
                else
                    aValues := nil 
                    if xmlChildEx(oResults:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETDATASETRESPONSE:_DATASET, "_VALUES") != nil
                        aValues := oResults:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETDATASETRESPONSE:_DATASET:_VALUES
                        if valType(aValues) == "O"
                            aValues  := oResults:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_GETDATASETRESPONSE:_DATASET:_VALUES:_VALUE
                            isUnique := .t.
                        endIf 
                    endIf 

                    if aValues == nil .or. empty(aValues)
                        oAlerts:Add('CNT6002:Fluig', ;
                                    'Sem dados do retorno!', ;
                                    'E', ;
                                    'Não existem dados no retorno.')
                    else 
                        if isUnique 
                            aAdd(aFolders, ;
                                {val(aValues[2]:TEXT), ;     //ID da pasta
                                 aValues[3]:TEXT})           //Descrição da pasta
                        else
                            for nValue := 1 to len(aValues)
                                aAdd(aFolders, ;
                                    {val(aValues[nValue]:_VALUE[2]:TEXT), ;     //ID da pasta
                                     aValues[nValue]:_VALUE[3]:TEXT})           //Descrição da pasta
                            next nValue
                        endIf
                    endIf
                endIf

                oResults := nil
            endif
        endif
    endif

    oFluig := nil
return(aFolders)


/*/{Protheus.doc} fluigInsert
Função para envio do arquivo anexo ao banco de conhecimento para o GED no Fluig
@author Odair Batista - TOTVS Unidade Londrina
@type Function
@since 26/10/2023
@version 1.0
@param cPath  , string, caminho físico do arquivo no servidor
@param cFile  , string, nome físico do arquivo no servidor
@param nFolder, number, ID da pasta no Fluig para anexar arquivo
@return string, número do ID do documento gerado no GED do Fluig
/*/
static function fluigInsert(cPath, cFile, nFolder)
    local cDoctoId  := ""
	local cEndPoint := superGetMv("MV_UFLGHOS", .f., "http://fluig.conasa.com:8072/")
	local cUser     := superGetMv("MV_UFLGUSR", .f., "integrator")
	local cPasswd   := superGetMv("MV_UFLGPWD", .f., "super")
    local cXML      := ""
    local oFluig    := nil
    local cResults  := ""
	local cMessage  := ''
	local cError    := ''
    local oResults  := nil
    local nHandle   := 0
    local aFiles    := {}
    local aSizes    := {}
    local cString   := ""
    local cBase64   := ""
    local nSize     := 0

    default cPath   := ""
    default cfile   := ""
    default nFolder := 1

	procRegua(0)
	incProc("Enviando...")

    //INICIO: Obtem dados do arquivo no formato base64
    aDir(cPath + cFile, aFiles, aSizes)
    nHandle := fOpen(cPath + cFile, FO_READWRITE + FO_SHARED)
    if nHandle == -1
        oAlerts:Add("CNT6002:Fluig", ;
                    "Arquivo não pode ser aberto!", ;
                    "E", ;
                    "Ocorreu um erro ao abrir o arquivo [" + cPath + cFile + "].")
        return("")
    endIf 

    cString := ""
    fRead(nHandle, cString, aSizes[1])

    cBase64 := encode64(cString) //Converte o arquivo para BASE64
    nSize   := aSizes[1]

    fclose(nHandle)
    //FIM: Obtem dados do arquivo no formato base64

	cXML := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.dm.webdesk.technology.datasul.com/">'
	cXML += '<soapenv:Header/>'
	cXML += '<soapenv:Body>'
	cXML += '  <ws:createDocument>'
	cXML += '    <username>' + cUser + '</username>'
	cXML += '    <password>' + cPasswd + '</password>'
	cXML += '    <companyId>1</companyId>'
	cXML += '    <Document>'
	cXML += '      <item>'
	cXML += '        <approvalAndOr>true</approvalAndOr>'
	cXML += '        <atualizationId>1</atualizationId>'
	cXML += '        <colleagueId>' + cUser + '</colleagueId>'
	cXML += '        <companyId>1</companyId>'
	cXML += '        <deleted>false</deleted>'
	cXML += '        <documentDescription>' + cFile + '</documentDescription>'
	cXML += '        <documentType>2</documentType>'
	cXML += '        <downloadEnabled>true</downloadEnabled>'
	cXML += '        <expires>false</expires>'
	cXML += '        <inheritSecurity>true</inheritSecurity>'
	cXML += '        <parentDocumentId>' + cValToChar(nFolder) + '</parentDocumentId>'
	cXML += '        <privateDocument>false</privateDocument>'
	cXML += '        <publisherId>' + cUser + '</publisherId>'
	cXML += '        <updateIsoProperties>true</updateIsoProperties>'
	cXML += '        <userNotify>false</userNotify>'
	cXML += '        <versionOption>0</versionOption>'
	cXML += '        <documentPropertyNumber>0</documentPropertyNumber>'
	cXML += '        <documentPropertyVersion>0</documentPropertyVersion>'
	cXML += '        <volumeId>Default</volumeId>'
	cXML += '        <languageId>pt</languageId>'
	cXML += '        <indexed>true</indexed>'
	cXML += '        <activeVersion>true</activeVersion>'
	cXML += '        <translated>false</translated>'
	cXML += '        <topicId>1</topicId>'
	cXML += '        <documentTypeId/>'
	cXML += '        <externalDocumentId/>'
	cXML += '        <datasetName/>'
	cXML += '        <versionDescription/>'
	cXML += '        <keyWord/>'
	cXML += '        <imutable>false</imutable>'
	cXML += '        <protectedCopy>false</protectedCopy>'
	cXML += '        <accessCount>0</accessCount>'
	cXML += '        <version>1000</version>'
	cXML += '      </item>'
	cXML += '    </Document>'
	cXML += '    <Attachments>'
	cXML += '      <item>'
	cXML += '        <fileName>' + cFile + '</fileName>'
	cXML += '        <principal>true</principal>'
	cXML += '        <fileSize>' + cValToChar(nSize) + '</fileSize>'
	cXML += '        <filecontent>' + cBase64 + '</filecontent>'
	cXML += '      </item>'
	cXML += '    </Attachments>'
	cXML += '    <security></security>'
	cXML += '    <Approvers></Approvers>'
	cXML += '    <RelatedDocuments></RelatedDocuments>'
	cXML += '  </ws:createDocument>'
	cXML += '</soapenv:Body>'
	cXML += '</soapenv:Envelope>'

    cEndPoint += if(subStr(cEndPoint, len(cEndPoint), 1) == "/", "", "/")
	cEndPoint += 'webdesk/ECMDocumentService?wsdl'

	oFluig := tWsdlManager():New()
	oFluig:lVerbose := .t.
	oFluig:nTimeout := 120
	oFluig:lSSLInsecure := .t.
	oFluig:bNoCheckPeerCert := .t.

	oFluig:AddHttpHeader("Accept-Encoding", "gzip,deflate")
	oFluig:AddHttpHeader("Content-Type", "text/xml;charset=UTF-8")
	oFluig:AddHttpHeader("Connection", "Keep-Alive")
	oFluig:AddHttpHeader("Content-Length", cValToChar(len(cXML)))
	oFluig:AddHttpHeader("Access-Control-Allow-Origin", "*")

    if !oFluig:ParseURL(cEndPoint)
        oAlerts:Add('CNT6002:Fluig', ;
                    'Processo não inicializado!', ;
                    'E', ;
                    'Não foi possível comunicação com o serviço Fluig.' + CRLF + allTrim(oFluig:cError))
    else
        if !oFluig:SetOperation('createDocument')
            oAlerts:Add('CNT6002:Fluig', ;
                        'Processo não inicializado!', ;
                        'E', ;
                        'Não foi possível requisitar o operador do serviço Fluig.' + CRLF + allTrim(oFluig:cError))
        else
            if !oFluig:SendSoapMsg(cXML)
                oAlerts:Add('CNT6002:Fluig', ;
                            'Processo não inicializado!', ;
                            'E', ;
                            'Não foi possível enviar requisição ao serviço Fluig.' + CRLF + allTrim(oFluig:cError))
            else
                //Trata o retorno da alteração do formulário para obter a nova versão gerada
                cResults := oFluig:GetSoapResponse()
                oResults := xmlParser(cResults, "_", @cMessage, @cError)
                if valType(oResults) != "O"
                    oAlerts:Add('CNT6002:Fluig', ;
                                'Processo sem retorno valido!', ;
                                'E', ;
                                'Não houve um retorno valido da requisição ao serviço Fluig.' ;
                                + CRLF + 'Aviso: [' + allTrim(cMessage) + CRLF + 'Erro:' + allTrim(cError)) 
                else
                    cMessage := oResults:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATEDOCUMENTRESPONSE:_RESULT:_ITEM:_WEBSERVICEMESSAGE:TEXT
                    if upper(allTrim(cMessage)) != 'OK'
                        oAlerts:Add('CNT6002:Fluig', ;
                                    'Processo sem retorno valido!', ;
                                    'E', ;
                                    'Não houve um retorno valido da requisição ao serviço Fluig. ' ;
                                    + CRLF + 'Mensagem: [' + allTrim(cMessage) + ']')
                    else
                        cDoctoId := oResults:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_CREATEDOCUMENTRESPONSE:_RESULT:_ITEM:_DOCUMENTID:TEXT
                        if empty(cDoctoId)
                            oAlerts:Add('CNT6002:Fluig', ;
                                        'Processo sem retorno valido!', ;
                                        'E', ;
                                        'Não houve um retorno valido da requisição ao serviço Fluig. ID do documento não identificado.')
                        endIf
                    endIf
                endIf

                oResults := nil
            endif
        endif
    endif

    oFluig := nil
return(cDoctoId)


/*/{Protheus.doc} fluigUpdate
Função para envio do arquivo anexo ao banco de conhecimento para o GED no Fluig para alteração
@author Odair Batista - TOTVS Unidade Londrina
@type Function
@since 27/10/2023
@version 1.0
@param cPath   , string, caminho físico do arquivo no servidor
@param cFile   , string, nome físico do arquivo no servidor
@param nFolder , number, ID da pasta no Fluig para anexar arquivo
@param nDoctoId, number, número do ID do documento gerado no GED do Fluig
@param cVersion, string, versão do arquivo
/*/
static function flgDocUpdate(cPath, cFile, nFolder, nDoctoId, cVersion)
	local cEndPoint := superGetMv("MV_UFLGHOS", .f., "http://fluig.conasa.com:8072/")
	local cUser     := superGetMv("MV_UFLGUSR", .f., "integrator")
	local cPasswd   := superGetMv("MV_UFLGPWD", .f., "super")
    local cXML      := ""
    local oFluig    := nil
    local cResults  := ""
	local cMessage  := ''
	local cError    := ''
    local oResults  := nil
    local nHandle   := 0
    local aFiles    := {}
    local aSizes    := {}
    local cString   := ""
    local cBase64   := ""
    local nSize     := 0

    default cPath    := ""
    default cfile    := ""
    default nFolder  := 1
    default nDoctoId := 0
    default cVersion := '1000'

	procRegua(0)
	incProc("Enviando...")

    //INICIO: Obtem dados do arquivo no formato base64
    aDir(cPath + cFile, aFiles, aSizes)
    nHandle := fOpen(cPath + cFile, FO_READWRITE + FO_SHARED)
    if nHandle == -1
        oAlerts:Add("CNT6002:Fluig", ;
                    "Arquivo não pode ser aberto!", ;
                    "E", ;
                    "Ocorreu um erro ao abrir o arquivo [" + cPath + cFile + "].")
        return
    endIf 

    cString := ""
    fRead(nHandle, cString, aSizes[1])

    cBase64 := encode64(cString) //Converte o arquivo para BASE64
    nSize   := aSizes[1]

    fclose(nHandle)
    //FIM: Obtem dados do arquivo no formato base64

	cXML := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.dm.webdesk.technology.datasul.com/">'
	cXML += '<soapenv:Header/>'
	cXML += '<soapenv:Body>'
	cXML += '  <ws:updateDocument>'
	cXML += '    <username>' + cUser + '</username>'
	cXML += '    <password>' + cPasswd + '</password>'
	cXML += '    <companyId>1</companyId>'
	cXML += '    <Document>'
	cXML += '      <item>'
	cXML += '        <approvalAndOr>true</approvalAndOr>'
	cXML += '        <atualizationId>1</atualizationId>'
	cXML += '        <colleagueId>' + cUser + '</colleagueId>'
	cXML += '        <companyId>1</companyId>'
	cXML += '        <deleted>false</deleted>'
    cXML += '        <approved>true</approved>'
	cXML += '        <documentId>' + cValToChar(nDoctoId) + '</documentId>'
	cXML += '        <documentDescription>' + cFile + '</documentDescription>'
	cXML += '        <documentType>2</documentType>'
	cXML += '        <downloadEnabled>true</downloadEnabled>'
	cXML += '        <expires>false</expires>'
	cXML += '        <inheritSecurity>true</inheritSecurity>'
	cXML += '        <parentDocumentId>' + cValToChar(nFolder) + '</parentDocumentId>'
	cXML += '        <privateDocument>false</privateDocument>'
	cXML += '        <publisherId>' + cUser + '</publisherId>'
	cXML += '        <updateIsoProperties>true</updateIsoProperties>'
	cXML += '        <userNotify>false</userNotify>'
	cXML += '        <versionOption>0</versionOption>'
	cXML += '        <documentPropertyNumber>0</documentPropertyNumber>'
	cXML += '        <documentPropertyVersion>0</documentPropertyVersion>'
	cXML += '        <volumeId>Default</volumeId>'
	cXML += '        <languageId>pt</languageId>'
	cXML += '        <indexed>true</indexed>'
	cXML += '        <activeVersion>true</activeVersion>'
	cXML += '        <translated>false</translated>'
	cXML += '        <topicId>1</topicId>'
    cXML += '        <documentTypeId>2</documentTypeId>'
	cXML += '        <externalDocumentId/>'
	cXML += '        <datasetName/>'
	cXML += '        <keyWord/>'
	cXML += '        <imutable>false</imutable>'
	cXML += '        <protectedCopy>false</protectedCopy>'
	cXML += '        <accessCount>0</accessCount>'
	cXML += '        <version>' + cVersion + '</version>'
	cXML += '        <versionDescription>Atualizado em ' + dToC(date()) + ' as ' + time() + '</versionDescription>'
    cXML += '        <validationStartDate>' + oUtils:DateToString(date(), "-", .t.) + 'T' + time() + '-03:00</validationStartDate>'
	cXML += '      </item>'
	cXML += '    </Document>'
	cXML += '    <Attachments>'
	cXML += '      <item>'
	cXML += '        <fileName>' + cFile + '</fileName>'
	cXML += '        <principal>true</principal>'
	cXML += '        <fileSize>' + cValToChar(nSize) + '</fileSize>'
	cXML += '        <filecontent>' + cBase64 + '</filecontent>'
	cXML += '      </item>'
	cXML += '    </Attachments>'
	cXML += '    <security></security>'
	cXML += '    <Approvers></Approvers>'
	cXML += '    <RelatedDocuments></RelatedDocuments>'
	cXML += '  </ws:updateDocument>'
	cXML += '</soapenv:Body>'
	cXML += '</soapenv:Envelope>'

    cEndPoint += if(subStr(cEndPoint, len(cEndPoint), 1) == "/", "", "/")
	cEndPoint += 'webdesk/ECMDocumentService?wsdl'

	oFluig := tWsdlManager():New()
	oFluig:lVerbose := .t.
	oFluig:nTimeout := 120
	oFluig:lSSLInsecure := .t.
	oFluig:bNoCheckPeerCert := .t.

	oFluig:AddHttpHeader("Accept-Encoding", "gzip,deflate")
	oFluig:AddHttpHeader("Content-Type", "text/xml;charset=UTF-8")
	oFluig:AddHttpHeader("Connection", "Keep-Alive")
	oFluig:AddHttpHeader("Content-Length", cValToChar(len(cXML)))
	oFluig:AddHttpHeader("Access-Control-Allow-Origin", "*")

    if !oFluig:ParseURL(cEndPoint)
        oAlerts:Add('CNT6002:Fluig', ;
                    'Processo não inicializado!', ;
                    'E', ;
                    'Não foi possível comunicação com o serviço Fluig.' + CRLF + allTrim(oFluig:cError))
    else
        if !oFluig:SetOperation('updateDocument')
            oAlerts:Add('CNT6002:Fluig', ;
                        'Processo não inicializado!', ;
                        'E', ;
                        'Não foi possível requisitar o operador do serviço Fluig.' + CRLF + allTrim(oFluig:cError))
        else
            if !oFluig:SendSoapMsg(cXML)
                oAlerts:Add('CNT6002:Fluig', ;
                            'Processo não inicializado!', ;
                            'E', ;
                            'Não foi possível enviar requisição ao serviço Fluig.' + CRLF + allTrim(oFluig:cError))
            else
                //Trata o retorno da alteração do formulário para obter a nova versão gerada
                cResults := oFluig:GetSoapResponse()
                oResults := xmlParser(cResults, "_", @cMessage, @cError)
                if valType(oResults) != "O"
                    oAlerts:Add('CNT6002:Fluig', ;
                                'Processo sem retorno valido!', ;
                                'E', ;
                                'Não houve um retorno valido da requisição ao serviço Fluig.' ;
                                + CRLF + 'Aviso: [' + allTrim(cMessage) + CRLF + 'Erro:' + allTrim(cError)) 
                else
                    cMessage := oResults:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_UPDATEDOCUMENTRESPONSE:_RESULT:_ITEM:_WEBSERVICEMESSAGE:TEXT
                    if upper(allTrim(cMessage)) != 'OK'
                        oAlerts:Add('CNT6002:Fluig', ;
                                    'Processo sem retorno valido!', ;
                                    'E', ;
                                    'Não houve um retorno valido da requisição ao serviço Fluig. ' ;
                                    + CRLF + 'Mensagem: [' + allTrim(cMessage) + ']')
                    endIf
                endIf

                oResults := nil
            endif
        endif
    endif

    oFluig := nil
return


/*/{Protheus.doc} fluigDelete
Função para envio do arquivo anexo ao banco de conhecimento para o GED no Fluig para eliminação
@author Odair Batista - TOTVS Unidade Londrina
@type Function
@since 27/10/2023
@version 1.0
@param nDoctoId, number, número do ID do documento gerado no GED do Fluig
/*/
static function fluigDelete(nDoctoId)
	local cEndPoint := superGetMv("MV_UFLGHOS", .f., "http://fluig.conasa.com:8072/")
	local cUser     := superGetMv("MV_UFLGUSR", .f., "integrator")
	local cPasswd   := superGetMv("MV_UFLGPWD", .f., "super")
    local cXML      := ""
    local oFluig    := nil
    local cResults  := ""
	local cMessage  := ''
	local cError    := ''
    local oResults  := nil

    default nDoctoId := 0

	procRegua(0)
	incProc("Removendo...")

	cXML := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.dm.webdesk.technology.datasul.com/">'
	cXML += '<soapenv:Header/>'
	cXML += '<soapenv:Body>'
	cXML += '  <ws:deleteDocument>'
	cXML += '    <user>' + cUser + '</user>'
	cXML += '    <password>' + cPasswd + '</password>'
	cXML += '    <companyId>1</companyId>'
	cXML += '    <documentId>' + cValToChar(nDoctoId) + '</documentId>'
    cXML += '    <colleagueId>' + cUser + '</colleagueId>'
	cXML += '  </ws:deleteDocument>'
	cXML += '</soapenv:Body>'
	cXML += '</soapenv:Envelope>'

    cEndPoint += if(subStr(cEndPoint, len(cEndPoint), 1) == "/", "", "/")
	cEndPoint += 'webdesk/ECMDocumentService?wsdl'

	oFluig := tWsdlManager():New()
	oFluig:lVerbose := .t.
	oFluig:nTimeout := 120
	oFluig:lSSLInsecure := .t.
	oFluig:bNoCheckPeerCert := .t.

	oFluig:AddHttpHeader("Accept-Encoding", "gzip,deflate")
	oFluig:AddHttpHeader("Content-Type", "text/xml;charset=UTF-8")
	oFluig:AddHttpHeader("Connection", "Keep-Alive")
	oFluig:AddHttpHeader("Content-Length", cValToChar(len(cXML)))
	oFluig:AddHttpHeader("Access-Control-Allow-Origin", "*")

    if !oFluig:ParseURL(cEndPoint)
        oAlerts:Add('CNT6002:Fluig', ;
                    'Processo não inicializado!', ;
                    'E', ;
                    'Não foi possível comunicação com o serviço Fluig.' + CRLF + allTrim(oFluig:cError))
    else
        if !oFluig:SetOperation('deleteDocument')
            oAlerts:Add('CNT6002:Fluig', ;
                        'Processo não inicializado!', ;
                        'E', ;
                        'Não foi possível requisitar o operador do serviço Fluig.' + CRLF + allTrim(oFluig:cError))
        else
            if !oFluig:SendSoapMsg(cXML)
                oAlerts:Add('CNT6002:Fluig', ;
                            'Processo não inicializado!', ;
                            'E', ;
                            'Não foi possível enviar requisição ao serviço Fluig.' + CRLF + allTrim(oFluig:cError))
            else
                //Trata o retorno da alteração do formulário para obter a nova versão gerada
                cResults := oFluig:GetSoapResponse()
                oResults := xmlParser(cResults, "_", @cMessage, @cError)
                if valType(oResults) != "O"
                    oAlerts:Add('CNT6002:Fluig', ;
                                'Processo sem retorno valido!', ;
                                'E', ;
                                'Não houve um retorno valido da requisição ao serviço Fluig.' ;
                                + CRLF + 'Aviso: [' + allTrim(cMessage) + CRLF + 'Erro:' + allTrim(cError)) 
                else
                    cMessage := oResults:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_DELETEDOCUMENTRESPONSE:_RESULT:_ITEM:_WEBSERVICEMESSAGE:TEXT
                    if upper(allTrim(cMessage)) != 'OK'
                        oAlerts:Add('CNT6002:Fluig', ;
                                    'Processo sem retorno valido!', ;
                                    'E', ;
                                    'Não houve um retorno valido da requisição ao serviço Fluig. ' ;
                                    + CRLF + 'Mensagem: [' + allTrim(cMessage) + ']')
                    endIf
                endIf

                oResults := nil
            endif
        endif
    endif

    oFluig := nil
return
