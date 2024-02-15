#include "totvs.ch"

static oDBase := pfwDBase():New()
static oDict  := pfwDict():New()

/*
Programa.: contratosFluig.prw
Tipo.....: Classe 
Autor....: Odair Batista - TOTVS OESTE (Unidade Londrina)
Data.....: 24/07/2023
Descri��o: Classe para atualiza��o de contratos p/ consultas Fluig
Notas....: 
*/
user function contratosFluig()
return(.t.) 


/*/{Protheus.doc} contratosFluig
Classe principal da classe contratosFluig
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type class
/*/
class contratosFluig from pfwAlerts
	data cClassName as string  hidden
    data oTable     as object  hidden

    data Table      as string
    data Anexos     as object
    data Available  as boolean
    data LoadAttach as boolean

	method New() constructor
	method ClassName()
	method Destroy()
	method Handle()

    method GetValue(cAttrib)
    method SetValue(cAttrib, xValue)

	method Clear()
	method CanFind(cOrigin, cNumber, cRevision)
	method Find(cOrigin, cNumber, cRevision)
	method FindByRecno(nRecno)
    method Load()
	method Validate(cMethod)
    method BeginRecord(cMethod)
    method EndRecord()
    method Commit(cMethod)
	method Insert()
	method Update()
	method Delete()
endClass               

                   
/*/{Protheus.doc} contratosFluig:New
M�todo construtor da classe contratosFluig
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0                        
@type constructor
@example
local oPedVenda := contratosFluig():New()
/*/
method New() class contratosFluig
	_Super:New()
	
	Self:cClassName := "contratosFluig"
    Self:Table      := getNextAlias()
	Self:Available  := .f.
    Self:LoadAttach := .t.
	Self:oTable     := oDBase:CreateTempTable(Self:Table, "ZAL")
    Self:Anexos     := contratosAnexos():New(Self)

	_Super:Empty()
return

           
/*/{Protheus.doc} contratosFluig:ClassName
M�todo respons�vel por retornar o nome da classe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method     
@return caractere, retorna o nome da classe
/*/
method ClassName() class contratosFluig
return Self:cClassName


/*/{Protheus.doc} contratosFluig:Destroy
M�todo destrutor do objeto, respons�vel pela desaloca��o da mem�ria
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method     
/*/  
method Destroy() class contratosFluig    
	local oSelf := Self:Handle()

    if valType(Self:Anexos) == "O"
        Self:Anexos:Destroy()
    endIf 

	if valType(Self:oTable) == "O"
		Self:oTable:Delete()
	endIf 
	
	freeObj(oSelf)	       
return


/*/{Protheus.doc} contratosFluig:Handle
M�todo obter o endre�o de mem�ria do pr�prio objeto
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method     
/*/  
method Handle() class contratosFluig
return(self)


/*/{Protheus.doc} contratosFluig:GetValue
M�todo obter o valor de um campo
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method    
@param cAttrib, string, Nome do atributo
@return, x, valor do atributo
/*/  
method GetValue(cAttrib) class contratosFluig
    local xValue := nil

    default cAttrib := ""

    if (Self:Table)->(fieldPos(cAttrib)) > 0 
        xValue := (Self:Table)->&(cAttrib)
    endIf
return(xValue)


/*/{Protheus.doc} contratosFluig:SetValue
M�todo setar um valor a um campo
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method    
@param cAttrib, string, Nome do atributo
@param xValue , x     , Valor do atributo
/*/  
method SetValue(cAttrib, xValue) class contratosFluig
    default cField := ""
    default xValue := nil 

    cAttrib := allTrim(cAttrib)

    if (Self:Table)->(fieldPos(cAttrib)) > 0 .and. !(Self:Table)->(eof())
        if cAttrib == "ZAL_ORIGEM"
            xValue := upper(xValue)
        endIf 

        (Self:Table)->&(cAttrib) := xValue
    endIf
return()


/*/{Protheus.doc} contratosFluig:Clear
M�todo limpar a classe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method     
/*/  
method Clear() class contratosFluig
    Self:Anexos:Clear()
	Self:Available := .f.

	oDBase:EmptyTempTable(Self:Table)
return()


/*/{Protheus.doc} contratosFluig:CanFind
M�todo verificar se o contrato existe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method    
@param cCodFil  , string, filial
@param cNumber  , string, n�mero do contrato
@param cOrigin  , string, origem do registro 
@param cRevision, string, revis�o
/*/  
method CanFind(cCodFil, cNumber, cOrigin, cRevision) class contratosFluig
    local areaDEF := getArea()
    local areaZAL := ZAL->(getArea())
    local isExist := .f.

    default cCodFil   := ""
    default cNumber   := ""
    default cOrigin   := ""
    default cRevision := ""

    dbSelectArea("ZAL")
    ZAL->(dbSetOrder(1))    //ZAL_FILIAL+ZAL_NUMERO+ZAL_ORIGEM+ZAL_REVISA

    cCodFil   := padR(allTrim(cCodFil), len(ZAL->ZAL_FILIAL), " ")
    cOrigin   := padR(allTrim(upper(cOrigin)), len(ZAL->ZAL_ORIGEM), " ")
    cNumber   := padR(allTrim(cNumber), len(ZAL->ZAL_NUMERO), " ")
    cRevision := padR(allTrim(cRevision), len(ZAL->ZAL_REVISA), " ")

    isExist := ZAL->(dbSeek(cCodFil + cNumber + cOrigin + cRevision))

    restArea(areaZAL)
    restArea(areaDEF)
return(isExist)


/*/{Protheus.doc} contratosFluig:Find
M�todo localizar um contrato e carregar dados no buffer
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method    
@param cCodFil  , string, filial
@param cNumber  , string, n�mero do contrato
@param cOrigin  , string, origem do registro 
@param cRevision, string, revis�o
/*/  
method Find(cCodFil, cNumber, cOrigin, cRevision) class contratosFluig
    local areaDEF := getArea()
    local areaZAL := ZAL->(getArea())

    default cCodFil   := ""
    default cNumber   := ""
    default cOrigin   := ""
    default cRevision := ""

    dbSelectArea("ZAL")
    ZAL->(dbSetOrder(1))    //ZAL_FILIAL+ZAL_NUMERO+ZAL_ORIGEM+ZAL_REVISA

    cCodFil   := padR(allTrim(cCodFil), len(ZAL->ZAL_FILIAL), " ")
    cOrigin   := padR(allTrim(upper(cOrigin)), len(ZAL->ZAL_ORIGEM), " ")
    cNumber   := padR(allTrim(cNumber), len(ZAL->ZAL_NUMERO), " ")
    cRevision := padR(allTrim(cRevision), len(ZAL->ZAL_REVISA), " ")

    if ZAL->(dbSeek(cCodFil + cNumber + cOrigin + cRevision))
		Self:Available := .t.
        areaZAL := ZAL->(getArea())
        areaDEF := Self:Load()
    else
        _Super:Add("contratosFluig:Find" ;
                   , "Registro n�o encontrado!" ;
                   , "E" ;
                   , "O registro com chave [" + cCodFil + ", " + cOrigin + ", " + cNumber + ", " + cRevision + "] n�o foi localizado. Verifique!")
    endIf

    restArea(areaZAL)
    restArea(areaDEF)
return(!_Super:HasErrors())

  
/*/{Protheus.doc} contratosFluig:FindByRecno
M�todo localizar um contrato pelo Recno
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 24/07/2023
@version 1.0
@type method    
@param nRecno, number, recno do contrato 
/*/  
method FindByRecno(nRecno) class contratosFluig
    local areaDEF := getArea()
    local areaZAL := ZAL->(getArea())

    dbSelectArea("ZAL")
    ZAL->(dbSetOrder(1))    //C5_FILIAL+C5_NUM
    ZAL->(dbGoTo(nRecno))    

	Self:Available := .f.

    if !ZAL->(eof())
		Self:Available := .t.
        areaDEF := Self:Load()
    else
        _Super:Add("contratosFluig:Find" ;
                   , "Registro n�o encontrado!" ;
                   , "E" ;
                   , "O registro com Recno [" + cValToChar(nRecno) + "] n�o foi localizado. Verifique!")
    endIf

    restArea(areaZAL)
    restArea(areaDEF)
return(!_Super:HasErrors())


/*/{Protheus.doc} contratosFluig:Load
M�todo carregar dados no buffer
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 25/07/2023
@version 1.0
@type method    
/*/  
method Load() class contratosFluig
    local areaDEF := getArea()
    local areaZAL := ZAL->(getArea())
    local areaZAM := ZAM->(getArea())
    local aFields := {}
    local nRow    := 0

	_Super:Empty()

    if ZAL->(eof())
        _Super:Add("contratosFluig:Find" ;
                   , "Registro n�o est� posicionado!" ;
                   , "E" ;
                   , "O registro n�o foi posicionado para carregamento. Verifique!")
    else
        Self:Available := .t.
        Self:Clear()    

        (Self:Table)->(recLock(Self:Table, .t.))
        oDBase:BufferCopy("ZAL", Self:Table)
        (Self:Table)->(msUnlock())

		areaDEF := ZAL->(getArea())
		areaZAL := ZAL->(getArea())

        if Self:LoadAttach 
            dbSelectArea("ZAM")
            ZAM->(dbSetOrder(1))    //ZAM_FILIAL+ZAM_NUMERO+ZAM_ORIGEM+ZAM_REVISA+ZAM_NOMEOR+ZAM_PATHOR
            ZAM->(dbSeek(ZAL->ZAL_FILIAL + ZAL->ZAL_NUMERO + ZAL->ZAL_ORIGEM + ZAL->ZAL_REVISA))

            if !ZAM->(eof())
                aFields := oDict:GetTableFields("ZAM", .f., .f.)

                do while !ZAM->(eof()) ;
                    .and. ZAM->ZAM_FILIAL == ZAL->ZAL_FILIAL ;
                    .and. ZAM->ZAM_NUMERO == ZAL->ZAL_NUMERO ;
                    .and. ZAM->ZAM_ORIGEM == ZAL->ZAL_ORIGEM ;
                    .and. ZAM->ZAM_REVISA == ZAL->ZAL_REVISA 

                    Self:Anexos:BeginRecord()
                    for nRow := 1 to len(aFields)
                        Self:Anexos:SetValue(aFields[nRow][1], ZAM->&(aFields[nRow][1]))
                    next nRow
                    Self:Anexos:EndRecord()

                    areaZAM := ZAM->(getArea())
                    ZAM->(dbSkip())
                end
            endIf 
        endIf 
    endIf

    restArea(areaZAM)
    restArea(areaZAL)
    restArea(areaDEF)
return(areaDEF)


/*/{Protheus.doc} contratosFluig:BeginRecord
M�todo para adicionar um novo registro a classe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 25/07/2023
@version 1.0
@type method     
@param cMethod, string, m�todo de execu��o
/*/  
method BeginRecord(cMethod) class contratosFluig
    default cMethod := "INSERT"

    cMethod := upper(allTrim(cMethod))
    if !(cMethod $ "INSERT|UPDATE")
        cMethod := "INSERT"
    endIf 

    if cMethod != "INSERT" ;
        .and. (Self:Table)->(eof())

        Self:Add("contratosFluig:EditRecord" ;
                 , "Registro n�o posicionado!" ;
                 , "E" ;
                 , "N�o existe um registro posisiconado para edi��o do contrato. Verifique!")
        return
    endIf

    (Self:Table)->(recLock(Self:Table, (cMethod == "INSERT")))
    Self:Available := .t.
return()


/*/{Protheus.doc} contratosFluig:EndRecord
M�todo para adicionar um novo registro a classe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 25/07/2023
@version 1.0
@type method     
/*/  
method EndRecord() class contratosFluig
    (Self:Table)->(msUnlock())
return()


/*/{Protheus.doc} contratosFluig:Commit
M�todo para setar os valores e gravar na tabela real
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 25/07/2023
@version 1.0
@type method     
@param cMethod, string, m�todo a ser executado "insert" ou "update"
/*/  
method Commit(cMethod) class contratosFluig
    local areaDEF := getArea()
    local areaZAL := ZAL->(getArea())
    local oHelper := pfwAlerts():New()
    local noCode  := .f.

    oHelper:Empty()

    (Self:Table)->ZAL_ORIGEM := upper((Self:Table)->ZAL_ORIGEM)

    dbSelectArea("ZAL")
    ZAL->(dbSetOrder(1))    //ZAL_FILIAL+ZAL_NUMERO+ZAL_ORIGEM+ZAL_REVISA
    ZAL->(dbSeek(xFilial("ZAL") + (Self:Table)->ZAL_NUMERO + (Self:Table)->ZAL_ORIGEM + (Self:Table)->ZAL_REVISA))

    if upper(alltrim(cMethod)) == "INSERT"
        if !ZAL->(eof())
            oHelper:Add("contratosFluig:Commit" ;
                        , "Contrato j� existe!" ;
                        , "E" ;
                        , "O Contrato com a chave [" + alltrim((Self:Table)->ZAL_NUMERO) + ", " + alltrim((Self:Table)->ZAL_ORIGEM) + ", " + alltrim((Self:Table)->ZAL_REVISA) + "] j� est� implantado.")
        else 
            ZAL->(recLock("ZAL", .t.))
            ZAL->ZAL_NUMERO := (Self:Table)->ZAL_NUMERO

            noCode := empty(ZAL->ZAL_NUMERO)
            if noCode
                ZAL->ZAL_NUMERO := getSxeNum("ZAL", "ZAL_NUMERO")
            endIf
        endIf 
    else
        if !ZAL->(eof())
            ZAL->(recLock("ZAL", .f.))
        else
            oHelper:Add("contratosFluig:Commit" ;
                        , "Contrato n�o encontrado!" ;
                        , "E" ;
                        , "O Contrato com a chave [" + alltrim((Self:Table)->ZAL_NUMERO) + ", " + alltrim((Self:Table)->ZAL_ORIGEM) + ", " + alltrim((Self:Table)->ZAL_REVISA) + "] n�o foi encontrado.")
        endIf 
    endIf 

    if oHelper:HasErrors()
        restArea(areaZAL)
        restArea(areaDEF)
    else
        oDBase:BufferCopy(Self:Table, "ZAL")
        ZAL->(msUnlock())

        if noCode .and. upper(alltrim(cMethod)) == "INSERT"
            confirmSx8()
        endIf
    endIf 

    _Super:AddFrom(oHelper)
    oHelper:Destroy()
return()


/*/{Protheus.doc} contratosFluig:Insert
M�todo adicionar um contrato
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 25/07/2023
@version 1.0
@type method     
/*/  
method Insert() class contratosFluig
    local areaDEF := getArea()
    local areaZAL := ZAL->(getArea())
    local areaZAM := ZAM->(getArea())

	if Self:Validate("insert")
        dbSelectArea("ZAL")
        ZAL->(dbSetOrder(1))    //ZAL_FILIAL+ZAL_NUMERO+ZAL_ORIGEM+ZAL_REVISA 

        dbSelectArea("ZAM")
        ZAM->(dbSetOrder(1))    //ZAM_FILIAL+ZAM_NUMERO+ZAM_ORIGEM+ZAM_REVISA+ZAM_NOMEOR+ZAM_PATHOR

        Self:Commit("insert")
        Self:Anexos:Commit("insert")
    endIf

    if _Super:HasErrors() 
        restArea(areaZAM)
        restArea(areaZAL)
        restArea(areaDEF)
    endIf
return(!_Super:HasErrors())


/*/{Protheus.doc} contratosFluig:Update
M�todo alterar um contrato
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 26/07/2023
@version 1.0
@type method     
/*/  
method Update() class contratosFluig
    local areaDEF := getArea()
    local areaZAL := ZAL->(getArea())
    local areaZAM := ZAM->(getArea())

	if Self:Validate("update")
        dbSelectArea("ZAL")
        ZAL->(dbSetOrder(1))    //ZAL_FILIAL+ZAL_NUMERO+ZAL_ORIGEM+ZAL_REVISA 

        dbSelectArea("ZAM")
        ZAM->(dbSetOrder(1))    //ZAM_FILIAL+ZAM_NUMERO+ZAM_ORIGEM+ZAM_REVISA+ZAM_NOMEOR+ZAM_PATHOR

        Self:Commit("update")
        Self:Anexos:Commit("update")
    endIf

    if _Super:HasErrors() 
        restArea(areaZAM)
        restArea(areaZAL)
        restArea(areaDEF)
    endIf
return(!_Super:HasErrors())


/*/{Protheus.doc} contratosFluig:Delete
M�todo eliminar um contrato
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 26/07/2023
@version 1.0
@type method     
/*/  
/*
method Delete() class contratosFluig
    local areaDEF := getArea()
    local areaZAL := ZAL->(getArea())
    local areaZAM := ZAM->(getArea())

	if Self:Validate("delete")
    endIf

    if _Super:HasErrors() 
        restArea(areaZAM)
        restArea(areaZAL)
        restArea(areaDEF)
    endIf
return(!_Super:HasErrors())
*/


/*/{Protheus.doc} contratosFluig:Validate
M�todo para valida��es 
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 26/07/2023
@version 1.0
@type method
@param  cMethod, string, Indica o m�todo para valida��o (Insert, Update ou Delete)
@return boolean, Indica se a valida��o ocorreu com sucesso (sem erros) ou n�o (com erros) 
/*/  
method Validate(cMethod) class contratosFluig
	local areaDEF   := getArea()
	local hasErrors := .f.
	local oHelper   := pfwAlerts():New()

	default cMethod := ""
	cMethod := lower(allTrim(cMethod))

	//Insert: Coloque aqui valida��es para insert
	if cMethod == "insert"
        if Self:CanFind((Self:Table)->ZAL_NUMERO, (Self:Table)->ZAL_ORIGEM, (Self:Table)->ZAL_REVISA)
            _Super:Add("contratosFluig:Validate" ;
                       , "N�mero j� implantado!" ;
                       , "E" ;
                       , "j� existe um contrato implantado com a chave [" + (Self:Table)->ZAL_NUMERO ;
                         + ", " + (Self:Table)->ZAL_ORIGEM + ", " + (Self:Table)->ZAL_REVISA + "]. Verifique!")
        elseIf val((Self:Table)->ZAL_TIPREV) == 0
            (Self:Table)->ZAL_TIPREV := "01"
        endIf
	endIf
	
	//Update: Coloque aqui valida��es para update
	if cMethod == "update" .or. cMethod == 'delete'
	endIf

	//Upsert: Coloque aqui valida��es em comum para insert ou update
	if cMethod == "insert" .or. cMethod == "update"		
        if empty((Self:Table)->ZAL_NUMERO)
            _Super:Add("contratosFluig:Validate" ;
                       , "N�mero n�o informado!" ;
                       , "E" ;
                       , "N�mero do contrato n�o foi informado. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_ORIGEM)
            _Super:Add("contratosFluig:Validate" ;
                       , "Origem n�o informada!" ;
                       , "E" ;
                       , "A origem do contrato n�o foi informada. Verifique!")
        elseIf !(allTrim((Self:Table)->ZAL_ORIGEM) $ "PROTHEUS|FLUIG")
            _Super:Add("contratosFluig:Validate" ;
                    , "Origem inv�lida!" ;
                    , "E" ;
                    , "A origem do contrato deve ser PROTHEUS ou FLUIG. Verifique!")
        endIf 

        if !empty((Self:Table)->ZAL_REVISA) 
            if empty((Self:Table)->ZAL_JUSTFI)
                _Super:Add("contratosFluig:Validate" ;
                        , "Justificativa n�o informada!" ;
                        , "E" ;
                        , "Para uma revis�o a justificativa � obrigat�ria. Verifique!")
            endIf 

            if empty((Self:Table)->ZAM_TIPREV)
                _Super:Add("contratosFluig:Validate" ;
                           , "Tipo da revis�o n�o informada!" ;
                           , "E" ;
                           , "O tipo da revis�o n�o foi informada. Verifique!")
            elseIf !(allTrim((Self:Table)->ZAM_TIPREV) $ "01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16") 
                _Super:Add("contratosFluig:Validate" ;
                           , "Tipo da revis�o inv�lido!" ;
                           , "E" ;
                           , "O tipo da revis�o com a chave [" + (Self:Table)->ZAM_TIPREV + "] � inv�lido. Verifique!")
            endIf 
        endIf 

        if empty((Self:Table)->ZAL_CC)
            _Super:Add("contratosFluig:Validate" ;
                       , "Centro de custo n�o informado!" ;
                       , "E" ;
                       , "O centro de custo do contrato n�o foi informado. Verifique!")
        elseIf empty(allTrim(posicione("CTT", 1, xFilial("CTT") + (Self:Table)->ZAL_CC, "CTT_CUSTO"))) 
            _Super:Add("contratosFluig:Validate" ;
                       , "Centro de custo n�o encontrado!" ;
                       , "E" ;
                       , "O centro de custo com a chave [" + (Self:Table)->ZAL_CC + "] n�o foi encontrado. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_SOLICI)
            _Super:Add("contratosFluig:Validate" ;
                       , "Solicitante n�o informado!" ;
                       , "E" ;
                       , "Solicitante do contrato n�o foi informado. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_FORNEC)
            _Super:Add("contratosFluig:Validate" ;
                       , "Fornecedor n�o informado!" ;
                       , "E" ;
                       , "O fornecedor do contrato n�o foi informado. Verifique!")
        elseIf empty(allTrim(posicione("SA2", 1, xFilial("SA2") + (Self:Table)->ZAL_FORNEC + (Self:Table)->ZAL_LOJA, "A2_COD"))) 
            _Super:Add("contratosFluig:Validate" ;
                       , "Fornecedor n�o encontrado!" ;
                       , "E" ;
                       , "O fornecedor com a chave [" + (Self:Table)->ZAL_FORNEC + ", " + (Self:Table)->ZAL_LOJA + "] n�o foi encontrado. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_SITUAC)
            _Super:Add("contratosFluig:Validate" ;
                       , "Situa��o n�o informada!" ;
                       , "E" ;
                       , "A situa��o do contrato n�o foi informada. Verifique!")
        elseIf !((Self:Table)->ZAL_SITUAC $ "01|02|03|04|05|06|07|08|09|10|A ") 
            _Super:Add("contratosFluig:Validate" ;
                       , "Situa��o inv�lida!" ;
                       , "E" ;
                       , "A situa��o do contrato com a chave [" + (Self:Table)->ZAL_SITUAC + "] � inv�lida. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_TIPCTR)
            _Super:Add("contratosFluig:Validate" ;
                       , "Tipo do contrato n�o informado!" ;
                       , "E" ;
                       , "O tipo do contrato n�o foi informado. Verifique!")
        elseIf empty(posicione("CN1", 1, xFilial("CN1") + (Self:Table)->ZAL_TIPCTR, "CN1->CN1_DESCRI"))
            _Super:Add("contratosFluig:Validate" ;
                       , "Tipo do contrato n�o encontrado!" ;
                       , "E" ;
                       , "O tipo do contrato com a chave [" + (Self:Table)->ZAL_TIPCTR + "] n�o foi encontrado. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_OBJETO)
            _Super:Add("contratosFluig:Validate" ;
                       , "Objeto n�o informado!" ;
                       , "E" ;
                       , "Objeto do contrato n�o foi informado. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_RESPJU)
            _Super:Add("contratosFluig:Validate" ;
                       , "Respons�vel jur�dico n�o informado!" ;
                       , "E" ;
                       , "Respons�vel jur�dico do contrato n�o foi informado. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_DTINIC)
            _Super:Add("contratosFluig:Validate" ;
                       , "Data in�cio n�o informada!" ;
                       , "E" ;
                       , "A data de in�cio do contrato n�o foi informada. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_DTFINA)
            _Super:Add("contratosFluig:Validate" ;
                       , "Data final n�o informada!" ;
                       , "E" ;
                       , "A data de finaliza��o do contrato n�o foi informada. Verifique!")
        endIf 

        if empty((Self:Table)->ZAL_DTASSI)
            _Super:Add("contratosFluig:Validate" ;
                       , "Data assinatura n�o informada!" ;
                       , "E" ;
                       , "A data de assinatura do contrato n�o foi informada. Verifique!")
        endIf 

        if (Self:Table)->ZAL_VALOR <= 0
            _Super:Add("contratosFluig:Validate" ;
                       , "Valor n�o informado!" ;
                       , "E" ;
                       , "Valor do contrato n�o foi informado. Verifique!")
        endIf 

        if (Self:Table)->ZAL_SALDO < 0
            _Super:Add("contratosFluig:Validate" ;
                       , "Saldo inv�lido!" ;
                       , "E" ;
                       , "Saldo do contrato n�o pode ser negativo. Verifique!")
        endIf 
	endIf
	
	//Delete: Coloque aqui valida��es para delete
	if cMethod == "Delete"
	endIf

    oHelper:Empty()
    Self:Anexos:Validate(cMethod, oHelper)
	_Super:AddFrom(oHelper)
	oHelper:Destroy()

	hasErrors := _Super:HasErrors()
	restArea(areaDEF)
return(!hasErrors)


/*/{Protheus.doc} contratosAnexos
Classe de controle de aneos de contratos Fluig
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type class
/*/
class contratosAnexos from LongNameClass
	data cClassName as string hidden
    data oTable     as object hidden
    data Parent     as object hidden

    data Table     as string
    data Available as boolean

	method New(oParent) constructor
	method ClassName()
	method Destroy()
	method Handle()

    method GetValue(cAttrib)
    method SetValue(cAttrib, xValue)

	method Clear()
	method CanFind(cOrigName, cOrigPath, cIdDoc)
	method Find(cOrigName, cOrigPath, cIdDoc)
	method Validate(cMethod, oAlerts)
    method BeginRecord(cMethod)
    method EndRecord()
    method Commit(cMethod)
endClass

                   
/*/{Protheus.doc} contratosAnexos:New
M�todo construtor da classe contratosAnexos
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0                        
@type constructor
@param oParent, object, objeto da classe principal
@example
local oAnexos := contratosAnexos():New()
/*/
method New(oParent) class contratosAnexos
	Self:cClassName := "contratosAnexos"
    Self:Table      := getNextAlias()
	Self:Available  := .f.
    Self:Parent     := oParent
	Self:oTable     := oDBase:CreateTempTable(Self:Table, "ZAM")
return

           
/*/{Protheus.doc} contratosAnexos:ClassName
M�todo respons�vel por retornar o nome da classe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method     
@return caractere, retorna o nome da classe
/*/
method ClassName() class contratosAnexos
return Self:cClassName


/*/{Protheus.doc} contratosAnexos:Destroy
M�todo destrutor do objeto, respons�vel pela desaloca��o da mem�ria
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method     
/*/  
method Destroy() class contratosAnexos
	local oSelf := Self:Handle()

	if valType(Self:oTable) == "O"
		Self:oTable:Delete()
	endIf 
	
	freeObj(oSelf)	       
return


/*/{Protheus.doc} contratosAnexos:Handle
M�todo obter o endre�o de mem�ria do pr�prio objeto
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method     
/*/  
method Handle() class contratosAnexos
return(self)


/*/{Protheus.doc} contratosAnexos:GetValue
M�todo obter o valor de um campo
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method    
@param cAttrib, string, Nome do atributo
@return, x, valor do atributo
/*/  
method GetValue(cAttrib) class contratosAnexos
    local xValue := nil

    default cAttrib := ""

    if (Self:Table)->(fieldPos(cAttrib)) > 0 
        xValue := (Self:Table)->&(cAttrib)
    endIf
return(xValue)


/*/{Protheus.doc} contratosAnexos:SetValue
M�todo setar um valor a um campo
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method    
@param cAttrib, string, Nome do atributo
@param xValue , x     , Valor do atributo
/*/  
method SetValue(cAttrib, xValue) class contratosAnexos
    local oUtils := nil 

    default cField := ""
    default xValue := nil 

    cAttrib := allTrim(cAttrib)
    if cAttrib == "ZAM_ORIGEM"
        xValue := upper(xValue)
    elseIf ((cAttrib == "ZAM_PATHOR" .or. cAttrib == "ZAM_PATHAR") .and. !empty(xValue))
        oUtils := pfwUtils():New()
        xValue := oUtils:CheckPath(xValue)
        oUtils:Destroy()
    endIf 

    if (Self:Table)->(fieldPos(cAttrib)) > 0 .and. !(Self:Table)->(eof())
        (Self:Table)->&(cAttrib) := xValue
    endIf
return()


/*/{Protheus.doc} contratosAnexos:Clear
M�todo limpar a classe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method     
/*/  
method Clear() class contratosAnexos
	oDBase:EmptyTempTable(Self:Table)
	Self:Available := .f.
return()


/*/{Protheus.doc} contratosAnexos:CanFind
M�todo verificar se a revisao do contrato existe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method    
@param cOrigName, string, nome original do arquivo
@param cOrigPath, string, caminho original do arquivo
@param cIdDoc   , string, Id do documento no Fluig
/*/  
method CanFind(cOrigName, cOrigPath, cIdDoc) class contratosAnexos
    local areaDEF := getArea()
    local isExist := .f.
    local oUtils  := nil

    default cOrigName := ""
    default cOrigPath := ""
    default cIdDoc    := ""

    dbSelectArea(Self:Table)
    (Self:Table)->(dbSetOrder(1))    //ZAM_FILIAL+ZAM_NUMERO+ZAM_ORIGEM+ZAM_REVISA+ZAM_NOMEOR

    if !empty(cOrigPath)
        oUtils := pfwUtils():New()
        cOrigPath := oUtils:CheckPath(cOrigPath)
        oUtils:Destroy()
    endIf 

    cOrigName := padR(alltrim(cOrigName), len((Self:Table)->ZAM_NOMEOR), "")
    cOrigPath := padR(alltrim(cOrigPath), len((Self:Table)->ZAM_PATHOR), "")
    cIdDoc    := padR(alltrim(cIdDoc)   , len((Self:Table)->ZAM_IDDOCT), "")

    isExist := (Self:Table)->(dbSeek(Self:Parent:GetValue("ZAL_FILIAL") + Self:Parent:GetValue("ZAL_NUMERO") + Self:Parent:GetValue("ZAL_ORIGEM") + Self:Parent:GetValue("ZAL_REVISA") + cOrigName + cOrigPath + cIdDoc))

    restArea(areaDEF)
return(isExist)


/*/{Protheus.doc} contratosAnexos:Find
M�todo localizar uma revis�o de contrato e carregar dados no buffer
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method    
@param cOrigName, string, nome original do arquivo
@param cOrigPath, string, caminho original do arquivo
@param cIdDoc   , string, Id do documento no Fluig
/*/  
method Find(cOrigName, cOrigPath, cIdDoc) class contratosAnexos
    local areaDEF   := getArea()
    local oHelper   := pfwAlerts():New()
    local hasErrors := .f.
    local oUtils    := nil

    default cOrigName := ""
    default cOrigPath := ""
    default cIdDoc    := ""

    oHelper:Empty()

    dbSelectArea(Self:Table)
    (Self:Table)->(dbSetOrder(1))    //ZAM_FILIAL+ZAM_NUMERO+ZAM_ORIGEM+ZAM_REVISA+ZAM_NOMEOR

    if !empty(cOrigPath)
        oUtils := pfwUtils():New()
        cOrigPath := oUtils:CheckPath(cOrigPath)
        oUtils:Destroy()
    endIf 

    cOrigName := padR(alltrim(cOrigName), len((Self:Table)->ZAM_NOMEOR), "")
    cOrigPath := padR(alltrim(cOrigPath), len((Self:Table)->ZAM_PATHOR), "")
    cIdDoc    := padR(alltrim(cIdDoc)   , len((Self:Table)->ZAM_IDDOCT), "")

    if (Self:Table)->(dbSeek(Self:Parent:GetValue("ZAL_FILIAL") + Self:Parent:GetValue("ZAL_NUMERO") + Self:Parent:GetValue("ZAL_ORIGEM") + Self:Parent:GetValue("ZAL_REVISA") + cOrigName + cOrigPath + cIdDoc))
		Self:Available := .t.
    else
		Self:Available := .f.
        /*
        oHelper:Add("contratosAnexos:Find" ;
                    , "Registro n�o encontrado!" ;
                    , "E" ;
                    , "O registro de anexo com chave [" + allTrim(cOrigName) + ", " + allTrim(cOrigPath) + ", " + allTrim(cIdDoc) + "] n�o foi localizado. Verifique!")
        */
    endIf

    hasErrors := oHelper:HasErrors()
    Self:Parent:AddFrom(oHelper)
    oHelper:Destroy()

    restArea(areaDEF)
return(!hasErrors)


/*/{Protheus.doc} contratosAnexos:Validate
M�todo para valida��es das revis�es
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method
@param  cMethod, string, Indica o m�todo para valida��o (Insert, Update ou Delete)
@param  oAlerts, object, Indica o objeto que recever� os avisos
@return boolean, Indica se a valida��o ocorreu com sucesso (sem erros) ou n�o (com erros) 
/*/  
method Validate(cMethod, oAlerts) class contratosAnexos
	local areaDEF   := getArea()
    local areaTMP   := (Self:Table)->(getArea())
	local hasErrors := .f.
	local oHelper   := pfwAlerts():New()

	default cMethod := ""
    default oAlerts := nil 

	cMethod := lower(allTrim(cMethod))

    oHelper:Empty()

    dbSelectArea(Self:Table)
    (Self:Table)->(dbSetOrder(1))
    (Self:Table)->(dbGoTop())

    do while !(Self:Table)->(eof())
        //Insert: Coloque aqui valida��es para insert
        if cMethod == "insert"
        endIf
        
        //Update: Coloque aqui valida��es para update
        if cMethod == "update" .or. cMethod == 'delete'
        endIf

        //Upsert: Coloque aqui valida��es em comum para insert ou update
        if cMethod == "insert" .or. cMethod == "update"	
            if empty((Self:Table)->ZAM_NOMEOR)
                oHelper:Add("contratosAnexos:Validate" ;
                            , "Arquivo n�o informado!" ;
                            , "E" ;
                            , "N�o foi informado um arquivo para anexar. Verifique!")
            endIf
        endIf
        
        //Delete: Coloque aqui valida��es para delete
        if cMethod == "Delete"
        endIf

        (Self:Table)->(dbSkip())
    endDo
	
	hasErrors := oHelper:HasErrors()

    if valType(oAlerts) == "O"
	    oAlerts:AddFrom(oHelper)
    else 
	    Self:Parent:AddFrom(oHelper)
    endIf 

	oHelper:Destroy()
	
	restArea(areaTMP)
	restArea(areaDEF)
return(!hasErrors)


/*/{Protheus.doc} contratosAnexos:BeginRecord
M�todo para adicionar um novo registro a classe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method     
@parma cMethod, string, m�todo de execu��o
/*/  
method BeginRecord(cMethod) class contratosAnexos
    default cMethod := "INSERT"

    cMethod := upper(allTrim(cMethod))
    if !(cMethod $ "INSERT|UPDATE")
        cMethod := "INSERT"
    endIf 

    if cMethod != "INSERT" ;
        .and. (Self:Table)->(eof())

        Self:Parent:Add("contratosAnexos:BeginRecord" ;
                        , "Registro n�o posicionado!" ;
                        , "E" ;
                        , "N�o existe um registro posicionado para edi��o de anexo. Verifique!")
        return
    endIf

    (Self:Table)->(recLock(Self:Table, (cMethod == "INSERT")))
    Self:Available := .t.
return()


/*/{Protheus.doc} contratosAnexos:EndRecord
M�todo para adicionar um novo registro a classe
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method     
/*/  
method EndRecord() class contratosAnexos
    (Self:Table)->(msUnlock())
return()


/*/{Protheus.doc} contratosAnexos:Commit
M�todo para setar os valores na tabela real
@author Odair Batista - TOTVS OESTE (Unidade Londrina)
@since 28/07/2023
@version 1.0
@type method     
@param cMethod, string, m�todo a ser executado "insert" ou "update"
/*/  
method Commit(cMethod) class contratosAnexos
    local areaDEF := getArea()
    local areaZAM := ZAM->(getArea())
    local oHelper := pfwAlerts():New()
	local oUtils  := pfwUtils():New()

    oHelper:Empty()

    dbSelectArea(Self:Table)
    (Self:Table)->(dbSetOrder(1))
    (Self:Table)->(dbGoTop())

    dbSelectArea("ZAM")
    ZAM->(dbSetOrder(1))    //ZAM_FILIAL+ZAM_NUMERO+ZAM_ORIGEM+ZAM_REVISA+ZAM_NOMEOR+ZAM_PATHOR+ZAM_IDDOCT

    //INICIO: remover arquivos inexistentes na tempor�ria
    if ZAM->(dbSeek((Self:Parent:Table)->ZAL_FILIAL + (Self:Parent:Table)->ZAL_NUMERO + (Self:Parent:Table)->ZAL_ORIGEM + (Self:Parent:Table)->ZAL_REVISA))
        do while !ZAM->(eof()) ;
            .and. ZAM->ZAM_FILIAL == (Self:Parent:Table)->ZAL_FILIAL ;
            .and. ZAM->ZAM_NUMERO == (Self:Parent:Table)->ZAL_NUMERO ;
            .and. ZAM->ZAM_ORIGEM == (Self:Parent:Table)->ZAL_ORIGEM ;
            .and. ZAM->ZAM_REVISA == (Self:Parent:Table)->ZAL_REVISA

            if !(Self:Table)->(dbSeek(ZAM->ZAM_FILIAL + ZAM->ZAM_NUMERO + ZAM->ZAM_ORIGEM + ZAM->ZAM_REVISA + ZAM->ZAM_NOMEOR + ZAM->ZAM_PATHOR + ZAM->ZAM_IDDOCT))
                ZAM->(recLock("ZAM", .f.))
                ZAM->(dbDelete())
                ZAM->(msUnlock())

                //Remove arquivo f�sico no servidor
                if file(allTrim(ZAM->ZAM_PATHAR) + allTrim(ZAM->ZAM_NOMEAR))
                    fErase(allTrim(ZAM->ZAM_PATHAR) + allTrim(ZAM->ZAM_NOMEAR))
                endIf 
            endIf 

            ZAM->(dbSkip())
        end 
    endIf 
    //FIm: remover arquivos inexistentes na tempor�ria

    //INICIO: gravar arquivos existentes na tempor�ria
    (Self:Table)->(dbGoTop())

    do while !(Self:Table)->(eof())
        if ZAM->(dbSeek(xFilial("ZAM") + (Self:Table)->ZAM_NUMERO + (Self:Table)->ZAM_ORIGEM + (Self:Table)->ZAM_REVISA + (Self:Table)->ZAM_NOMEOR))
            ZAM->(recLock("ZAM", .f.))
        else
            ZAM->(recLock("ZAM", .t.))
        endIf 

        if oHelper:HasErrors()
            restArea(areaZAM)
            restArea(areaDEF)
        else
            if empty((Self:Table)->ZAM_FILIAL)
                (Self:Table)->ZAM_FILIAL := Self:Parent:GetValue("ZAL_FILIAL")
            endIf

            if empty((Self:Table)->ZAM_NUMERO)
                (Self:Table)->ZAM_NUMERO := Self:Parent:GetValue("ZAL_NUMERO")
            endIf

            if empty((Self:Table)->ZAM_ORIGEM)
                (Self:Table)->ZAM_ORIGEM := Self:Parent:GetValue("ZAL_ORIGEM")
            endIf

            if empty((Self:Table)->ZAM_REVISA)
                (Self:Table)->ZAM_REVISA := Self:Parent:GetValue("ZAL_REVISA")
            endIf

			if empty((Self:Table)->ZAM_PATHAR)
				(Self:Table)->ZAM_PATHAR := superGetMv("MV_UPTHANX", .f., "resources\contratosAnexos\")
			endIf

			if empty((Self:Table)->ZAM_NOMEAR)
				(Self:Table)->ZAM_NOMEAR := allTrim(cEmpAnt) ;
				                             + "." + allTrim(cFilAnt) ;
											 + "." + strZero(val(Self:Parent:GetValue("ZAL_FORNEC")), 9) + strZero(val(Self:Parent:GetValue("ZAL_LOJA")), 3) ;
											 + "." + subStr(allTrim((Self:Table)->ZAM_NOMEOR), 7, len(allTrim((Self:Table)->ZAM_NOMEOR)))
			endIf

            if !empty((Self:Table)->ZAM_PATHOR)
			    (Self:Table)->ZAM_PATHOR := oUtils:CheckPath((Self:Table)->ZAM_PATHOR)
            endIf 

            if !empty((Self:Table)->ZAM_PATHAR)
			    (Self:Table)->ZAM_PATHAR := oUtils:CheckPath((Self:Table)->ZAM_PATHAR, .t.)
            endIf 

            oDBase:BufferCopy(Self:Table, "ZAM")
            ZAM->(msUnlock())
        endIf 

        (Self:Table)->(dbSkip())
    end
    //FIM: gravar arquivos existentes na tempor�ria

    Self:Parent:AddFrom(oHelper)
    oHelper:Destroy()
	oUtils:Destroy()
return()

