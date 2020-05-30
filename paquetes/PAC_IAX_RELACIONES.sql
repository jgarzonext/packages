--------------------------------------------------------
--  DDL for Package PAC_IAX_RELACIONES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AXIS"."PAC_IAX_RELACIONES" IS
   /******************************************************************************
      NOMBRE:       PAC_IAX_RELACIONES
      PROPÓSITO:    Funciones de la capa IAX para realizar acciones sobre la tabla RELACIONES

      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        12/07/2012   APD             1. Creación del package. 0022494: MDP_A001- Modulo de relacion de recibos
   ******************************************************************************/

   /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
    param in pcempres     : codigo empresa
    param in pcagente     : codigo de agente
    param in psrelacion     : codigo de la relacion
    param in pfiniefe     : Fecha de inicio de efecto , del recibo dentro de la relación
    param in pffinefe     : Fecha de fin del recibo, dentro de la relación
    param out prelaciones  : sys_refcursor de las relaciones que cumplan los busqueda
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_obtener_relaciones(
      pcempres IN NUMBER,
      pcagente IN NUMBER,
      psrelacion IN NUMBER,
      pfiniefe IN DATE,
      pffinefe IN DATE,
      prelaciones OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
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
      ptob_iax_relaciones OUT t_iax_relaciones,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

      /*
   F_GUARDAR_RECIBO EN_RELACION
    crear una nueva relación con todos los recibos que se han informado */
   FUNCTION f_guardar_recibo_en_relacion(
      ptiaxinfo IN t_iax_info,
      pcagente IN NUMBER,
      psrelacion OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
    Función que realiza la búsqueda de relaciones a partir de los criterios de consulta entrados
    param in pnrecibo     : numero de recibo
    param out precibo     : sys_refcursor con el recibo que cumplan los busqueda
    param out mensajes    : colección de objetos ob_iax_mensajes
         return             : 0 busqueda correcta
                           <> 0 busqueda incorrecta
   *************************************************************************/
   FUNCTION f_get_reg_retro_cobro_masivo(
      pnrecibo IN NUMBER,
      precibo OUT sys_refcursor,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

   /*************************************************************************
         Función que retrocede el cobro (impaga) una lista de recibos, con un
         motivo por recibo y a una fecha común.

           param in pcempres : Còdigo de empresa
           param in pnliqmen : Número de liquidación mensual
           param in plistrecibos: Lista de recibos y motivos de impago
           param in pfretro : Fecha de retrocesión de los cobros
           param in out mensaje : mensajes de error

           La lista de recibos/motivos tendrá como separador ";" para separar los
           recibos y "," para separar motivo de recibo, ejemplo:

           recibos1,motivo1;recibos2,motivo2;recibos3,motivo3;recibos4,motivo4;

           return : number
    *************************************************************************/
   FUNCTION f_set_retro_cobro_masivo(
      pcempres IN NUMBER,
      psproliq IN NUMBER,
      plistrecibos IN VARCHAR2,
      pfretro IN DATE,
      psmovagr OUT NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER;

       /*************************************************************************
    Función que consulta los recibos retrocedibles sobre los que podremos
    retroceder el pago (impagarlos).

      param in pcempres : Còdigo de empresa
      param in psproliq : Número de proceso de la liquidación
      param in out mensaje : mensajes de error

      NOTA:
      Queda pendiente de considerar los recibos "por reemplazo":
      1. La query ha de excluirlos.
      2. Cuando la búsqueda es por recibo ha de avisar si lo es.

      Datos de la query:

        4. NANUALI - Anualidad
        5. NFRACCI - Fracción
        6. FCESTREC- F. Cobro
        7. TTIPCOB - T. Cobro (RECIBOS.CBANCAR IS NULL --> Domiciliado, ELSE --> Medidador)
        8. TPRODUC - Producto
        9. NPOLIZA - Nº póliza
        10.CAGENTE - Mediador
        11.ITOTALR - Total recibo
        12.NREMESA - Nº Remesa
        13.NLIQMEN - Nº Liquidación
        14.NRELREC - Nº Relación
        15.FEMISIO - Fecha emisión
        16.FEFECTO - Fecha efecto
        17.FVENCIM - Fecha vencimiento

      return : number
   *************************************************************************/
   FUNCTION f_get_retro_cobro_masivo(
      pcempres IN NUMBER,
      psproliq IN NUMBER,
      pcidioma IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor;
END pac_iax_relaciones;

/

  GRANT EXECUTE ON "AXIS"."PAC_IAX_RELACIONES" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RELACIONES" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_IAX_RELACIONES" TO "PROGRAMADORESCSI";
