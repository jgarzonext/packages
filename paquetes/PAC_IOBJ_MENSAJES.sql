--------------------------------------------------------
--  DDL for Package PAC_IOBJ_MENSAJES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IOBJ_MENSAJES" AS
/******************************************************************************
   NOMBRE:      PAC_IOBJ_MENSAJES
   PROPÓSITO:   Funciones para la gestion de error y avisos de la aplicación

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        16/01/2008   ACC               1. Creación del package.
******************************************************************************/

    /*************************************************************************
       Graba los errores que se produzcan en la base de datos
       param in ptobjeto  : objeto que produce el error
       param in pntraza   : número de traza
       param in ptdescrip : descripcón error
       param in pterror   : mensaje error
    *************************************************************************/
    PROCEDURE P_GrabaDBError (ptobjeto IN VARCHAR2, pntraza IN NUMBER,
                           ptdescrip IN VARCHAR2, pterror IN VARCHAR2);

    /*************************************************************************
       Devuelve el objeto mensaje
       param in tipo     : tipo de error 1 error 2 aviso
       param in nerror   : código de error
       param in idioma   : código del idioma del mensaje
       param in mensaje  : se puede informar el texto del mensaje, si se
                            informa se muestra el mensaje sino se recupera el
                            literal
       return            : objeto mensajes
    *************************************************************************/
    FUNCTION F_Set_Mensaje(tipo number,nerror number,idioma number,
                         mensaje varchar2  DEFAULT '*') RETURN OB_IAX_MENSAJES;

    /*************************************************************************
       Devuelve el literal del código de error
       param in cerror   : código de error
       param in idioma   : código del idioma del mensaje
       return            : texto del mensaje de error
    *************************************************************************/
    FUNCTION F_Get_DescMensaje(cerror IN NUMBER, idioma IN NUMBER) RETURN VARCHAR;

    /*************************************************************************
       Devuelve el literal del código de error
       param in cerror   : código de error
       return            : texto del mensaje de error
    *************************************************************************/
    FUNCTION F_Get_DescMensaje(cerror IN NUMBER) RETURN VARCHAR;

    /*************************************************************************
       Hace un merge en dos colecciones de mensajes
       param in mensajesDst : coleccion mensajes destino
       param in mensajes    : coleccion mensajes a merge

    *************************************************************************/
    PROCEDURE P_MergeMensaje(mensajesDst IN OUT T_IAX_MENSAJES, mensajes in T_IAX_MENSAJES);

    /*************************************************************************
       Trata mensajes de error para excepciones
       param in out mensajes    : coleccion mensajes
       param in pfuncion         : nombre de la función
       param in pnerror          : número de error
       param in ptraza           : número de traza
       param in pparams          : parametros de la función
       param in pterror          : texto del mensaje a concatenar
       param in psqcode          : número error sqlcode
       param in psqerrm          : mensaje error sqlerrm
    *************************************************************************/
    PROCEDURE P_TratarMensaje(mensajes IN OUT T_IAX_MENSAJES,
                              pfuncion  IN VARCHAR2,
                              pnerror   IN NUMBER,
                              ptraza    IN NUMBER,
                              pparams   IN VARCHAR,
                              pterror   IN VARCHAR2 DEFAULT NULL,
                              psqcode   IN NUMBER DEFAULT NULL,
                              psqerrm   IN VARCHAR2 DEFAULT NULL);

    /*************************************************************************
       Crea un registro nuevo de error
       param in out mens : colección de posibles errores
       param in tipo     : tipo de error 1 error 2 aviso
       param in nerror   : código de error
       param in mensaje  : se puede informar el texto del mensaje, si se
                            informa se muestra el mensaje sino se recupera el
                            literal
    *************************************************************************/
    PROCEDURE Crea_Nuevo_Mensaje(mens IN OUT T_IAX_MENSAJES,
                    tipo number, nerror number, mensaje varchar2  DEFAULT '*');

    /*************************************************************************
       Crea un registro nuevo de error compuestos
       param in out mens : colección de posibles errores
       param in tipo     : tipo de error 1 error 2 aviso
       param in nerror   : código de error
       param in varmsg   : colección de variables a sustituir en el texto
                            del mensaje
       param in separador: como se limita el valor sustituir
       param in mensaje  : se puede informar el texto del mensaje, si se
                            informa se muestra el mensaje sino se recupera el
                            literal
    *************************************************************************/
    PROCEDURE Crea_Nuevo_Mensaje_Var(mens IN OUT T_IAX_MENSAJES,
                     tipo number, nerror number, varmsg T_IAX_MSGVARIABLES,
                     separador varchar2 DEFAULT '$',mensaje varchar2 DEFAULT '*');

    /*************************************************************************
       Crea un registro nuevo de error compuestos
       param in out mens : colección de posibles errores
       param in tipo     : tipo de error 1 error 2 aviso
       param in nerror   : código de error
       param in varmsg   : String con los elementos de la variables
       param in ptipo    : para la variables indicadas són del tipo DEFAULT NULL
                            1 varchar   2 codigo literal
       param in separador: como se limita el valor sustituir
       param in mensaje  : se puede informar el texto del mensaje, si se
                            informa se muestra el mensaje sino se recupera el
                            literal
    *************************************************************************/
    PROCEDURE Crea_Nuevo_Mensaje_Var(mens IN OUT T_IAX_MENSAJES,
                     tipo number, nerror number, varmsg varchar2,ptipo IN NUMBER DEFAULT NULL,
                     separador varchar2 DEFAULT '$',mensaje varchar2 DEFAULT '*');

    /*************************************************************************
       Crea el objeto variables de mensajes a partir del parametro
       param in variables : variables separadas por #
       return             : objeto variables de mensajes
    *************************************************************************/
    FUNCTION Crea_Variables_Mensaje(variables IN VARCHAR2,
                                    ptipo IN NUMBER DEFAULT NULL) RETURN T_IAX_MSGVARIABLES;

END PAC_IOBJ_MENSAJES;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_IOBJ_MENSAJES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IOBJ_MENSAJES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IOBJ_MENSAJES" TO "PROGRAMADORESCSI";
