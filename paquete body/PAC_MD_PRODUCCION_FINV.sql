--------------------------------------------------------
--  DDL for Package Body PAC_MD_PRODUCCION_FINV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_MD_PRODUCCION_FINV" AS
   /******************************************************************************
      NOMBRE:      PAC_MD_PRODUCCION_FINV
      PROPÓSITO:   Funciones para la producción en segunda capa de productos financieros
                   de inversión.
      REVISIONES:
      Ver        Fecha        Autor             Descripción
      ---------  ----------  ---------------  ------------------------------------
      1.0        16/03/2008   RSC               1. Creación del package.
   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;

   /*************************************************************************
      Graba en el objeto poliza la distribución seleccionada
      param in pcmodelo  : Código de modelo de inversión
      param in ppoliza   : Objeto póliza
      param out mensajes : mensajes de error
      return             : number
   *************************************************************************/
   FUNCTION f_grabar_modeloinvfinv(
      pcmodelo IN NUMBER,
      ppoliza IN OUT ob_iax_poliza,
      mensajes OUT t_iax_mensajes)
      RETURN NUMBER IS
      vtprefor       VARCHAR2(100);
      v_resp         NUMBER;
      distr          ob_iax_produlkmodelosinv;
      num_err        NUMBER;
      vaux           NUMBER;

      CURSOR c_modelos(pcramo NUMBER, pcmodali NUMBER, pctipseg NUMBER, pccolect NUMBER) IS
         SELECT m.ccodfon, f.tfonabv, m.pinvers
           FROM modinvfondo m, fondos f
          WHERE cmodinv = pcmodelo
            AND m.ccodfon = f.ccodfon
            AND cramo = pcramo
            AND cmodali = pcmodali
            AND ctipseg = pctipseg
            AND ccolect = pccolect;

      w_err          PLS_INTEGER;
      w_pas_exec     PLS_INTEGER := 1;
      w_param        VARCHAR2(500) := 'parametres: pcmodelo =' || pcmodelo;
      w_object       VARCHAR2(200) := 'PAC_MD_PRODUCCION_FINV.f_grabar_modeloinvFinv';
      v_exist        NUMBER := 0;
   BEGIN
      IF ppoliza.det_poliza IS NULL THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, -456,
                                              'No se ha inicializado correctamente');
         RAISE e_param_error;
      END IF;

      w_pas_exec := 2;
      distr := ppoliza.det_poliza.modeloinv;

      IF distr.cmodinv IS NULL
         OR distr.cmodinv <> pcmodelo THEN
         distr.cmodinv := pcmodelo;
         distr.modinvfondo := t_iax_produlkmodinvfondo();
      END IF;

      IF NVL(f_parproductos_v(pac_iax_produccion.vproducto, 'PERFIL_LIBRE'), 0) <> pcmodelo THEN
         -- Detalle del modelo de inversión
         FOR regs IN c_modelos(ppoliza.det_poliza.cramo, ppoliza.det_poliza.cmodali,
                               ppoliza.det_poliza.ctipseg, ppoliza.det_poliza.ccolect) LOOP
            w_pas_exec := 3;

            IF distr.modinvfondo IS NOT NULL THEN
               IF distr.modinvfondo.COUNT > 0 THEN
                  FOR i IN distr.modinvfondo.FIRST .. distr.modinvfondo.LAST LOOP
                     IF regs.ccodfon = distr.modinvfondo(i).ccodfon THEN
                        v_exist := 1;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

            w_pas_exec := 4;

            IF v_exist <> 1 THEN
               distr.modinvfondo.EXTEND;
               distr.modinvfondo(distr.modinvfondo.LAST) := ob_iax_produlkmodinvfondo();
               distr.modinvfondo(distr.modinvfondo.LAST).ccodfon := regs.ccodfon;
               distr.modinvfondo(distr.modinvfondo.LAST).tcodfon := regs.tfonabv;
               distr.modinvfondo(distr.modinvfondo.LAST).pinvers := regs.pinvers;
               distr.modinvfondo(distr.modinvfondo.LAST).cobliga := 1;
               v_exist := 0;
            END IF;
         END LOOP;
      ELSE
         distr.cmodinv := pcmodelo;

         FOR regs IN c_modelos(ppoliza.det_poliza.cramo, ppoliza.det_poliza.cmodali,
                               ppoliza.det_poliza.ctipseg, ppoliza.det_poliza.ccolect) LOOP
            w_pas_exec := 5;

            IF distr.modinvfondo IS NOT NULL THEN
               IF distr.modinvfondo.COUNT > 0 THEN
                  FOR i IN distr.modinvfondo.FIRST .. distr.modinvfondo.LAST LOOP
                     IF regs.ccodfon = distr.modinvfondo(i).ccodfon THEN
                        v_exist := 1;
                     END IF;
                  END LOOP;
               END IF;
            END IF;

            w_pas_exec := 6;

            IF v_exist <> 1 THEN
               distr.modinvfondo.EXTEND;
               distr.modinvfondo(distr.modinvfondo.LAST) := ob_iax_produlkmodinvfondo();
               distr.modinvfondo(distr.modinvfondo.LAST).ccodfon := regs.ccodfon;
               distr.modinvfondo(distr.modinvfondo.LAST).tcodfon := regs.tfonabv;
               distr.modinvfondo(distr.modinvfondo.LAST).pinvers := regs.pinvers;
            END IF;

            v_exist := 0;
         END LOOP;
      END IF;

      w_pas_exec := 3;
      -- Grabamos de nuevo la distribucion en el objeto póliza
      ppoliza.det_poliza.modeloinv := distr;
      RETURN(0);
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, w_object, 1000001, w_pas_exec, w_param,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN(1);
   END f_grabar_modeloinvfinv;
END pac_md_produccion_finv;

/

  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_FINV" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_FINV" TO "CONF_DWH";
  GRANT EXECUTE ON "AXIS"."PAC_MD_PRODUCCION_FINV" TO "PROGRAMADORESCSI";
