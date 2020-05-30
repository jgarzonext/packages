--------------------------------------------------------
--  DDL for Package PAC_RELACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_RELACIONES" IS
   /******************************************************************************
      NOMBRE:       PAC_RELACIONES
      PROPÓSITO:    Funciones de la capa lógica para realizar acciones sobre la tabla RELACIONES

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/07/2012   APD             1. Creación del package. 0022494: MDP_A001- Modulo de relacion de recibos
      2.0        17/06/2015   MMS             2. Rediseño de Relaciones (0036392: agregar un campo de factura a los recibos que agrupados y agrupador en colectivos)
   ******************************************************************************/

   /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in psrelacion   : codigo de la relacion
    param in pfiniefe     : Fecha de inicio de efecto , del recibo dentro de la relación
    param in pffinefe     : Fecha de fin del recibo, dentro de la relación
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_obtener_relaciones(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psrelacion IN NUMBER,
      pfiniefe IN DATE,
      pffinefe IN DATE,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

          /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
        PCAGENTE IN  NUMBER
        PCRELACION IN NUMBER
        PCTIPO IN NUNBER ( tipo de busqueda  DEFAULT 0)
        TSELECT OUT VARCHAR2

         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_set_recibos_relacion(
      pcagente IN NUMBER,
      pcrelacion IN NUMBER,
      pnrecibo IN NUMBER,
      pctipo IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

        /*
   F_GUARDAR_RECIBO EN_RELACION
    crear una nueva relación con todos los recibos que se han informado */
   FUNCTION f_guardar_recibo_en_relacion(
      pnrecibo IN NUMBER,
      pcagente IN NUMBER,
      pcrelacion IN NUMBER,
      pctipo IN NUMBER)
      RETURN NUMBER;

    /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
    param in pcempres     : numero de recibo
    param in pcidioma     : codigo del idioma
    param out pquery      : select a ejcutar
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_reg_retro_cobro_masivo(
      pnrecibo IN NUMBER,
      pcidioma IN NUMBER,
      pquery OUT VARCHAR2)
      RETURN NUMBER;

-- Bug 0036392 MMS 20150617
    /*************************************************************************
    Función que crea una cabecera de una relación
    param in pmes_ano     : number
    param in pnfactura    : varchar2
    param in pcagente     : number
    param out psrelacion  : number
         return             : 0 insert correcto
                           <> 0 insert incorrecto
   *************************************************************************/
   FUNCTION f_set_relacion(
      pmes_ano IN NUMBER,
      pnfactura IN VARCHAR2,
      pcagente IN NUMBER,
      psrelacion OUT NUMBER)
      RETURN NUMBER;

    /*************************************************************************
    Función que realiza la vallidación de una cabecera de una relación
    param in pmes_ano     : number
    param in pnfactura    : varchar2
    param in pcagente     : number
         return             : 0 insert correcto
                           <> 0 insert incorrecto
   *************************************************************************/
   FUNCTION f_existe_relacion(pmes_ano IN NUMBER, pnfactura IN VARCHAR2)
      RETURN NUMBER;
END pac_relaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_RELACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_RELACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_RELACIONES" TO "PROGRAMADORESCSI";
