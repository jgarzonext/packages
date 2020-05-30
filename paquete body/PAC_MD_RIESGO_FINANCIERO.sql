create or replace PACKAGE BODY pac_md_riesgo_financiero AS
   /*****************************************************************************
      NAME:       pac_md_caja_cheque
      PURPOSE:    Funciones de obtenci¿n de datos de CTACLIENTE

      REVISIONS:
      Ver        Date        Author           Description
      ---------  ----------  ---------------  ------------------------------------
      1.0        25/02/2013   AFM             1. Creaci¿n del package.

   ******************************************************************************/
   e_object_error EXCEPTION;
   e_param_error  EXCEPTION;
   mensajes       t_iax_mensajes := NULL;
   gidioma        NUMBER := pac_md_common.f_get_cxtidioma;
   gempres        NUMBER := pac_md_common.f_get_cxtempresa;

   /*************************************************************************
        Obtiene los cheques filtrados por ncheque o sperson
        param in sperson  : Codigo del Usuario
        param in ncheque : Numero d cheque
        param out mensajes : mensajes de error
        return             : 0 si todo ha ido bien o 1
     *************************************************************************/
   /*FUNCTION f_lee_cheques(
      sperson IN NUMBER,
      ncheque IN VARCHAR2,
      pseqcaja IN NUMBER,
      mensajes OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'sperson= ' || sperson || ' ncheque=' || ncheque;
      vobject        VARCHAR2(200) := 'PAC_IAX_CAJA_CHEQUE.f_lee_cheques';
      cur            sys_refcursor;
      vtselect       VARCHAR2(4000);
      vnumerr        NUMBER(4);
   BEGIN
      vnumerr := pac_caja_cheque.f_lee_cheques(sperson, ncheque, pseqcaja, vtselect);

      IF vnumerr <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, vnumerr);
         RAISE e_object_error;
      END IF;

      cur := pac_iax_listvalores.f_opencursor(vtselect, mensajes);
      RETURN cur;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN NULL;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN NULL;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);

         IF cur%ISOPEN THEN
            CLOSE cur;
         END IF;

         RETURN cur;
   END f_lee_cheques;*/

    /*************************************************************************
      Edita el estado y la fecha de los cheques
      param in pscaja : Codigo de cheque
      param in pestado: estado del cheque
      param in pfecha: Fecha del cheque
      param out mensajes : mensajes de error
   *************************************************************************/
  /* FUNCTION f_set_estadocheques(
      pscaja IN NUMBER,
      pestado IN NUMBER,
      pfecha IN DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
                      := 'pscaja=' || pscaja || ' pestado=' || pestado || ' pfecha=' || pfecha;
      vobject        VARCHAR2(200) := 'pac_md_caja_cheque.f_set_estadocheques';
      nerror         NUMBER := 0;
   BEGIN
      vpasexec := 15;
      nerror := pac_caja_cheque.f_set_estadocheques(pscaja, pestado, pfecha);

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;
      --
      vpasexec := 16;
      --
      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_set_estadocheques;

    /*************************************************************************
      Devuelve un la cantidad de veces que este el seq que se le pase en pagos masivos
      param in pscaja : Codigo de cheque
      param out mensajes : mensajes de error
       return             : 0 si no existe en la tabla pagos_masivos
   *************************************************************************/
 /*  FUNCTION f_protestado(pscaja IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200) := 'pscaja=' || pscaja;
      vobject        VARCHAR2(200) := 'pac_caja_cheque.f_protestado';
      nerror         NUMBER := 0;
   BEGIN
      vpasexec := 15;
      nerror := pac_caja_cheque.f_protestado(pscaja);
      vpasexec := 16;

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_protestado;

   /*************************************************************************
        Inserta registros en el historico de movimientos
        param in seqcaja : Secuencial del movimiento
        param in ncheque : Numero de cheque
        param in cstchq: Estado del cheque (0 pendiente, 1 Aceptado, 3 protestado)
        param in cstchq_ant : Estado del cheque Anterior (0 pendiente, 1 Aceptado, 3 protestado)
        param in festado : Estado del cheque anterior
        param in out mensajes : mensajes de error
         return             : 0 si no existe en la tabla pagos_masivos
     *************************************************************************/
  /* FUNCTION f_insert_historico(
      seqcaja NUMBER,
      ncheque VARCHAR2,
      cstchq NUMBER,
      cstchq_ant NUMBER,
      festado DATE,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(200)
         := 'seqcaja=' || seqcaja || ' ncheque=' || ncheque || ' cstchq=' || cstchq
            || ' cstchq_ant=' || cstchq_ant || ' festado=' || festado;
      vobject        VARCHAR2(200) := 'f_insert_historico';
      nerror         NUMBER := 0;
   BEGIN
      vpasexec := 15;
      nerror := pac_caja_cheque.f_insert_historico(seqcaja, ncheque, cstchq, cstchq_ant,
                                                   festado);
      vpasexec := 16;

      IF nerror <> 0 THEN
         pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
         RAISE e_object_error;
      END IF;

      RETURN nerror;
   EXCEPTION
      WHEN e_param_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000005, vpasexec, vparam);
         RETURN 1;
      WHEN e_object_error THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000006, vpasexec, vparam);
         RETURN 1;
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_insert_historico;
*/
   FUNCTION f_calcula_riesgo(
      sperson IN NUMBER,
      fefecto IN DATE,
      monto IN NUMBER,
      mensajes IN OUT t_iax_mensajes)
      RETURN NUMBER IS
      vpasexec       NUMBER(8) := 1;
      v_directorio   VARCHAR2(500);
      vparam         VARCHAR2(200)
                        := 'sperson=' || sperson || ' fefecto=' || fefecto || ' monto=' || monto;
      vobject        VARCHAR2(200) := 'pac_md_riesgo_financiero.f_calcula_riesgo';
      nerror         NUMBER := 0;
   BEGIN
      vpasexec := 15;
      nerror := pac_riesgo_financiero.f_calculo_riesgo(sperson, fefecto, monto);
      p_tab_error(f_sysdate, f_user, vobject, vpasexec, vparam, 'nerrr: : '||nerror);
      vpasexec := 16;

    --INI - AXIS 2554 - 10/5/2019 - AABG - SE AGREGA CONTROL DE EXCEPCION NUMERO 2 PARA CUANDO NO EXISTA INFORMACION 
      IF nerror <> 0 THEN
        IF nerror = 1 THEN
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 1, nerror);
             RAISE e_object_error;
        ELSE
             pac_iobj_mensajes.crea_nuevo_mensaje(mensajes, 2, 89906305);
             RAISE e_object_error;
        END IF;

      END IF;
    --FIN - AXIS 2554 - 10/5/2019 - AABG - SE AGREGA CONTROL DE EXCEPCION NUMERO 2 PARA CUANDO NO EXISTA INFORMACION
      RETURN nerror;
   EXCEPTION
      WHEN OTHERS THEN
         pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject, 1000001, vpasexec, vparam,
                                           psqcode => SQLCODE, psqerrm => SQLERRM);
         RETURN 1;
   END f_calcula_riesgo;

    FUNCTION F_GET_RIESGOS_CALCULADOS(sperson IN NUMBER, mensajes IN OUT t_iax_mensajes)
      RETURN sys_refcursor IS
      vpasexec       NUMBER(8) := 1;
      vparam         VARCHAR2(2000) := 'sperson= ' || sperson;
      vobject        VARCHAR2(200) := 'pac_md_riesgo_financiero.F_GET_RIESGOS_CALCULADOS';
      cur       sys_refcursor;
  BEGIN

    cur := pac_riesgo_financiero.F_GET_RIESGOS_CALCULADOS(sperson);
      RETURN cur;

    RETURN NULL;
    EXCEPTION

WHEN e_param_error THEN
PAC_IOBJ_MENSAJES.P_TRATARMENSAJE(MENSAJES, VOBJECT,1000005, VPASEXEC, VPARAM);
RETURN null;

WHEN e_object_error THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000006, vpasexec, vparam);
RETURN null;

WHEN OTHERS THEN
pac_iobj_mensajes.p_tratarmensaje(mensajes, vobject,1000001, vpasexec, vparam,
NULL,SQLCODE,SQLERRM);
RETURN null;
  END F_GET_RIESGOS_CALCULADOS;


END pac_md_riesgo_financiero;