--------------------------------------------------------
--  DDL for Package PAC_ASEGURADORAS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_ASEGURADORAS" AS
/*************************************************************************
   FUNCTION F_GET_TRASPASO
   Función que sirve para recuperar los datos de una/varias aseguradoras
        1.  PCEMPRES: Tipo numérico. Parámetro de entrada. Código de traspaso
        2.  PCODASEG: Tipo numérico. Parámetro de entrada. Código de traspaso
        3.  PCODDIGO: Tipo numérico. Parámetro de entrada. Código del plan
        4.  PCODDEP: Tipo numérico. Parámetro de entrada. Código de la depositaria
        5.  PCODDGS: Tipo VARCHAR2. Parámetro de entrada. Código DGS de la aseguradora
        6.  pfdatos: Tipo numérico. Parámetro de Salida. Cursor con la/las aseguradoras planes requeridas.

   Retorna 0 OK 1 KO.
*************************************************************************/
   FUNCTION f_get_aseguradoras(
      pcempres IN NUMBER,
      pccodaseg IN NUMBER,
      pccodigo IN NUMBER,
      pccoddep IN NUMBER,
      pccoddgs IN VARCHAR2,
      pnombre IN VARCHAR2,
      pctrasp IN NUMBER,   --indica si solo consultamos las de ctrasp = 1 o todas
      pfdatos OUT sys_refcursor)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_del_aseguradoras
   Función que sirve para borrar los datos de una aseguradora (y sus planes)
        1.  PCCODASE: Tipo numérico. Parámetro de entrada. Código de la aseguradora
        2.  PCODDGS: Tipo VARCHAR2. Parámetro de entrada. Código DGS de la aseguradora
        Uno al menos informado.

   Retorna 0 OK 1 KO.
*************************************************************************/
   FUNCTION f_del_aseguradoras(pccodaseg IN NUMBER, pccoddgs IN VARCHAR2)
      RETURN NUMBER;

/*************************************************************************
   FUNCTION f_del_aseguradoras_planes
   Función que sirve para borrar los datos de una aseguradora (y sus planes)
        1.  PCCODASE: Tipo numérico. Parámetro de entrada. Código de la aseguradora
        2.  PCCODIGO: Tipo numérico. Parámetro de entrada. Código del plan
        Uno al menos informado.

   Retorna 0 OK 1 KO.
*************************************************************************/
   FUNCTION f_del_aseguradoras_planes(pccodaseg IN NUMBER, pccodigo IN NUMBER)
      RETURN NUMBER;

/*************************************************************************
       F_SET_ASEGURADORAS
Función que sirve para insertar o actualizar datos del aseguradoras.
Parámetros

      vccodaseg in VARCHAR2,
      vsperson in NUMBER,
      vccodban in NUMBER,
      vcbancar in VARCHAR2,
      vcempres in NUMBER,
      vccoddep in NUMBER,
      vccoddgs in VARCHAR2,
      vctipban in NUMBER)

Retorna 0 ok/ 1 KO
*************/
   FUNCTION f_set_aseguradoras(
      vccodaseg VARCHAR2,
      vsperson NUMBER,
      vccodban NUMBER,
      vcbancar VARCHAR2,
      vcempres NUMBER,
      vccoddep NUMBER,
      vccoddgs VARCHAR2,
      vctipban NUMBER,
      vclistblanc NUMBER)
      RETURN NUMBER;

/*************************************************************************
       F_GET_NOMASEG
Función que sirve para recuperar el nommbre de la aseguradora
Parámetros

      vsperson in NUMBER
Retorna el VARCHAR con su nombre (null si va mal)
*************************************************************************/
   FUNCTION f_get_nomaseg(vsperson IN NUMBER)
      RETURN VARCHAR2;
END pac_aseguradoras;
 
 

/

  GRANT EXECUTE ON "AXIS"."PAC_ASEGURADORAS" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_ASEGURADORAS" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_ASEGURADORAS" TO "PROGRAMADORESCSI";
