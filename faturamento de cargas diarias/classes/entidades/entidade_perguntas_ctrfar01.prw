#include "totvs.ch"

CLASS EntidadePerguntasCTRFAR01 FROM LongNameClass
	DATA dDataIni
	DATA dDataFim
	DATA cOSIni
	DATA cOSFim
	DATA cIdZ29Ini
	DATA cIdZ29Fim
	DATA cClieIni
	DATA cLojaIni
	DATA cClieFim
	DATA cLojaFim
	DATA dDtFatIni
	DATA dDtFatFim
	DATA cNFIni
	DATA cNFFim
	DATA cSerieIni
	DATA cSerieFim
	METHOD New() CONSTRUCTOR
ENDCLASS

METHOD New() CLASS EntidadePerguntasCTRFAR01
	::dDataIni := CToD("")
	::dDataFim := CToD("")
	::cOSIni := ""
	::cOSFim := ""
	::cIdZ29Ini := ""
	::cIdZ29Fim := ""
	::cClieIni := ""
	::cLojaIni := ""
	::cClieFim := ""
	::cLojaFim := ""
	::dDtFatIni := CToD("")
	::dDtFatFim := CToD("")
	::cNFIni := ""
	::cNFFim := ""
	::cSerieIni := ""
	::cSerieFim := ""
Return
