--------------------------------------------------------
--  DDL for Package PAC_CONVIVENCIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_CONVIVENCIA" AS

/****************************************************************************
    F_GET_IAXIS: Devuelve el valor (String) de un detalle o columna basada en la tabla CON_HOMOLOGA_OSIAX
    Parameters:
                 PSPERSON : Identificación de la persona en iAxis (Per_persona)
                 PQUERY_SELECT : Query Select a ejecutar que devuelve el valor de detalle o campo de iAxis
                 PTIPO_CAMPO: Tipo de campo (varchar, date, number).
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/02/2019   CES             Función para obtener el valor de un detalle o campo en iAxis amarrado al SPERSON
****************************************************************************/
FUNCTION F_GET_IAXIS(PSPERSON VARCHAR2, PQUERY_SELECT VARCHAR2, PTIPO_CAMPO VARCHAR2) RETURN VARCHAR2;

/****************************************************************************
    P_SEND_DATA: Realiza la ejecución de los script de integración Osiris - iAxis
    Parameters:
                 PSPERSON : Identificación de la persona en iAxis (Per_persona)
                 PFLAG :    Bandera para saber si es un insert(0) o update(1)
                 PTABLA:    Nombre de la tabla a utilizar en la actualización.
   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/02/2019   CES - WAJ       Procedimiento encargado de realizar el envio de los datos a core OSIRIS
****************************************************************************/
PROCEDURE P_SEND_DATA (PSPERSON IN VARCHAR2, PFLAG IN NUMBER, PTABLA IN VARCHAR2);

/****************************************************************************
    f_convivencia_Osiris: DEVUELVE LA DATA NECESARIA PARA EL PROCESO DE CONVIVENCIA
    Parameters:
            PSPERSON : Identificación de la persona en iAxis (Per_persona)
            PNFORMAT = 1 = HOMOLOGACION TIPPER PARA OSIRIS
            PNFORMAT = 2 = TREAR EL CAMPO CDOMICI PARA CONCATENAR CON EL SPERSON

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/02/2019   WAJ           FUNCION CONVIVENCIA IAXIS - OSIRIS
****************************************************************************/
FUNCTION f_convivencia_Osiris(
   psperson IN NUMBER,
   pnformat IN NUMBER)
   RETURN VARCHAR2;

/****************************************************************************
    F_GET_COD_OSIRIS: Devuelve el código de la persona el tabla s03500 de Osiris
    Parameters:
            PSPERSON : Identificación de la persona en iAxis (Per_persona)
            PDBLINK :  Nmbre del dblink

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        26/02/2019   CESS            Función que devuelve el valor de codigo o codigo principal de la tabla de osiris S03500, para los que hayan sido migrados devolvera el código para los nuevos en la tabla no existen entonces devolvera PSPERSON+IDDOMICI
****************************************************************************/
FUNCTION F_GET_COD_OSIRIS (PSPERSON VARCHAR2, PDBLINK VARCHAR2, PEXISTE OUT VARCHAR) RETURN VARCHAR2;

/****************************************************************************
    F_MARCAS_VINCULO: Devuelve los vinculos y su valor (0,1) si la persona tiene marca
    Parameters:
            PSPERSON : Identificación de la persona en iAxis (Per_persona)

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/02/2019   WAJ            Función que devuelve el valor del vinculo segun la marca que tenga
****************************************************************************/
FUNCTION f_marcas_vinculo(PSPERSON NUMBER) RETURN marcas_type_marcas;

/****************************************************************************
    F_OSIRIS_MARCAS: Realiza validacion si el tercero tiene marca en Osiris, si la tiene la actualiza, si no la crea en Osiris
    Parameters:
            PSPERSON : Identificación de la persona en iAxis (Per_persona)

   REVISIONES:
   Ver        Fecha        Autor             Descripción
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/02/2019   WAJ            Realiza validacion si el tercero tiene marca en Osiris, si la tiene la actualiza, si no la crea en Osiris
****************************************************************************/
FUNCTION f_Osiris_marcas(PSPERSON NUMBER) RETURN VARCHAR2;


--FUNCTION f_marcas_vin(psperson in  NUMBER)
 --  RETURN marcas_type_marcas;
 
/*Cambios para tarea IAXIS-13044 : Start */   
  PROCEDURE P_SEND_DATA_CONVI(PNNUMIDE IN VARCHAR2,
                              PFLAG    IN NUMBER,
                              PTABLA   IN VARCHAR2,
                              PSINTERF IN NUMBER);

  PROCEDURE P_SET_ESTADO(PI_SINTERF      IN NUMBER,
                         PI_NNUMIDE      IN VARCHAR2,
                         PI_TABLA_OSIRIS IN VARCHAR2,
                         PI_OPERACION    IN VARCHAR2,
                         PI_ESTADO       IN NUMBER,
                         PI_RESPUESTA    IN VARCHAR2);

  PROCEDURE P_SET_MARCAS_VINDULO(PI_NNUMIDE    IN VARCHAR2,
                                 PI_CODIGO     IN NUMBER,
                                 PI_CODIGO_OSI IN VARCHAR2,
                                 PI_CTIPPER    IN NUMBER,
                                 PI_SINTERF    IN NUMBER,
                                 PI_DBLINK     IN VARCHAR2);
								 
  FUNCTION F_GET_NOMBRE(PI_SPERSON IN NUMBER) RETURN VARCHAR2;                                 
  
/*Cambios para tarea IAXIS-13044 : End */  

END PAC_CONVIVENCIA;

/

  GRANT EXECUTE ON "AXIS"."PAC_CONVIVENCIA" TO "R_AXIS";
