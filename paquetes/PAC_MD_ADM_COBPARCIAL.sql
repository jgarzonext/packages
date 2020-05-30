CREATE OR REPLACE PACKAGE pac_md_adm_cobparcial IS
   /******************************************************************************
    NOMBRE:      PAC_MD_adm_cobparcial
    PROPÓSITO:   Funciones para las interfases en segunda capa
    REVISIONES:
    Ver        Fecha        Autor             Descripción
    ---------  ----------  ---------------  ------------------------------------
    1.0        19/09/2012  JGR              0022346 LCOL_A003-Cobro parcial de los recibos Fase 2
    2.0        18/10/2013  JGR              0028577: POSND100-Añadir nota en la agenda del recibo en el momento de que SAP nos envie un recaudo.
    3.0        07/06/2019  JLTS             IAXIS.4153: Se incluyen nuevos paráametros pnreccaj y pcmreca a la función f_cobro_parcial_recibo
    4.0        18/07/2019  SHAKTI           IAXIS.4753: Ajuste campos Servicio L003
    5.0        01/08/2019  Shakti    	      IAXIS-4944 TAREAS CAMPOS LISTENER
    6.0        12/09/2019  DFRP             IAXIS-4884: Paquete de integración pagos SAP
    7.0        04/12/2019  DFRP             IAXIS-7640: Ajuste paquete listener para Recaudos SAP
   ******************************************************************************/

   -- 1.0  19/09/2012 JGR 0022346 LCOL_A003-Cobro parcial de los recibos Fase 2 - Inicio
   /*******************************************************************************
   FUNCION PAC_adm_cobparcial.F_COBRO_PARCIAL_RECIBO
   Registra los cobros parciales de los recibos.
   Sí los cobros parciales igualan el total del recibo este se dará por cobrado.
   Sí los cobros parciales superan el total del recibo dará un error.

   Parámetros:
     param in pnrecibo  : Número de recibo
     param in pctipcob  : Tipo de cobro (V.F.: 552)
     param in piparcial : Importe del cobro parcial
     param in pcmoneda  : Código de moneda (inicialmente no se tiene en cuenta)
     return: number un número con el id del error, en caso de que todo vaya OK, retornará un cero.
   ********************************************************************************/
   FUNCTION f_cobro_parcial_recibo(
      --
      -- Inicio IAXIS-7640 04/12/2019
      --
      --pnrecibo IN NUMBER,
      pnrecibo IN VARCHAR2,
      --
      -- Fin IAXIS-7640 04/12/2019
      --
      pctipcob IN NUMBER,
      piparcial IN NUMBER,
      pcmoneda IN NUMBER,
      mensajes IN OUT t_iax_mensajes,
      -- 2.0  0028577 - Inicio
      pnrecsap IN VARCHAR2 DEFAULT NULL,   -- Número de recaudo en SAP
      pcususap IN VARCHAR2 DEFAULT NULL,   -- Usuario originador en SAP
                                       -- 2.0  0028577 - Inicio
      -- INI -IAXIS-4153 - JLTS 07/06/2019 Se adicionan los campos cmreca y nreccaj
      pnreccaj IN VARCHAR2 DEFAULT NULL,/* Cambios de IAXIS-4753 */
      pcmreca  IN NUMBER DEFAULT NULL ,
      -- FIN -IAXIS-4153 - JLTS 07/06/2019
      pcindicaf IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      pcsucursal IN VARCHAR2 DEFAULT NULL ,------Changes for 4944
      pndocsap IN VARCHAR2 DEFAULT NULL, ------Changes for 4944
      pctipotransap IN NUMBER DEFAULT NULL -- IAXIS-4884 12/09/2019
   )
      RETURN NUMBER;
-- 1.0  19/09/2012 JGR 0022346 LCOL_A003-Cobro parcial de los recibos Fase 2 - Fin
END pac_md_adm_cobparcial;
/
