--------------------------------------------------------
--  DDL for Package Body PAC_REF_SINIES_REN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "AXIS"."PAC_REF_SINIES_REN" 
AS

  FUNCTION f_aperturar_siniestro(psseguro IN NUMBER, pnriesgo IN NUMBER, pfsinies IN DATE, pfnotifi IN DATE, ptsinies IN VARCHAR2,
             pcmotsin IN NUMBER, pcidioma IN NUMBER, pcidioma_user IN NUMBER DEFAULT F_IdiomaUser,
              oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
  RETURN NUMBER IS
    /************************************************************************************************************************************
       Función que inicializa el siniestro y mira qué tipo de siniestro debe abrir
       Parámetros de entrada: psseguro = Identificador de la póliza
                              pnriesgo =  Riesgo o asegurado al que se imputa el siniestro.
                                          Si la póliza es de un producto a 2 cabezas se indicará el asegurado (asegurados.norden),
                                          sino el riesgo (riesgo.nriesgo)
                              pfsinies = Fecha de ocurrencia del siniestro
                              pfnotifi = Fecha de notificación (Por defecto debe valer Trunc(F_Sysdate))
                              ptsinies = Observaciones
                              pcmotsin = Motivo del siniestro
                              pcidioma = Idioma de la documentación
                              pcidioma_user = Idioma del usuario
       Parámetros de salida: ocoderror =  Si hay error: código de error. Si no hay error: Null
                             omsgerror = Si hay error: texto de error. Si no hay error: Null
     ******************************************************************************************************************************************/

   BEGIN

     Return(        Pac_Ref_Sinies_Aho.f_aperturar_siniestro(psseguro , pnriesgo , pfsinies , pfnotifi, ptsinies ,
                                                                          pcmotsin , pcidioma, pcidioma_user , oCODERROR , oMSGERROR ));




   EXCEPTION
     WHEN OTHERS THEN
        oCODERROR := -999;
        oMSGERROR := 'Pac_Ref_Sinies_Ren.f_aperturar_siniestro: Error general en la función';
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Sinies_Ren.f_aperturar_siniestro',NULL,
                    'parametros: psseguro = '||psseguro||'  pnriesgo = '||pnriesgo||' pfsinies = '||pfsinies||'  ptsinies = '||ptsinies||
                    ' pfnotifi = '||pfnotifi||' pcmotsin = '||pcmotsin||' pcidioma = '||pcidioma||' pcidioma_user = '||pcidioma_user,
                      SQLERRM);
        Rollback;
        RETURN NULL;
   END f_aperturar_siniestro;


FUNCTION f_valida_permite_rescate_total(psseguro IN NUMBER, pcagente in number, pfrescate IN DATE, pcidioma_user IN NUMBER default F_IdiomaUser,
                              oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2)
  RETURN NUMBER IS

begin


     return(Pac_Ref_Sinies_Aho.f_valida_permite_rescate_total(psseguro, pcagente, pfrescate, pcidioma_user,oCODERROR, oMSGERROR));


EXCEPTION
   WHEN OTHERS THEN
      ocoderror := 108190;  -- Error General
      omsgerror := f_literal(ocoderror, pcidioma_user);
      p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Sinies_Ren.f_valida_permite_rescate_total',NULL,
        'parametros: psseguro='||psseguro||' pcagente='||pcagente||' pfrescate ='||pfrescate,
        SQLERRM);
      return null;
end f_valida_permite_rescate_total;

/*
FUNCTION f_sim_rescate_total(psseguro in number, pcagente in number, pfrescate in date,
   pcidioma in number, pcidioma_user in number,  cavis out number, lavis out varchar2,oCODERROR OUT NUMBER,
   oMSGERROR OUT VARCHAR2)
  RETURN cursor_type IS


   v_cursor   cursor_type;

begin



     Return (Pac_Ref_Sinies_Aho.f_sim_rescate_total(psseguro, pcagente, pfrescate,pcidioma, pcidioma_user,
                                                                                           cavis, lavis,oCODERROR,oMSGERROR));


EXCEPTION
   WHEN OTHERS THEN
      ocoderror := 180561;  -- Error General
      omsgerror := f_literal(ocoderror, pcidioma_user);
      p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Sinies_Ren.f_sim_rescate_total',NULL,
        'parametros: psseguro='||psseguro||' pcagente='||pcagente||' pfrescate ='||pfrescate,
        SQLERRM);
      rollback;
      RETURN v_cursor;

end f_sim_rescate_total;
*/


FUNCTION f_sim_rescate_total(psseguro in number, pcagente in number, pfrescate in date,
   pcidioma in number, pcidioma_user in number,  cavis out number, lavis out varchar2,oCODERROR OUT NUMBER,
   oMSGERROR OUT VARCHAR2)
  RETURN cursor_type IS


/*****************************************************************************************
      Función que simula un rescate.  Se establecerán controles para asegurar que el cálculo
      es correcto. Si se detecta algún error entonces se dará el siguiente mensaje
       'No se puede realizar simulación sobre esta póliza. ¿Proceder al rescate?'.
       De esta forma evitaremos mostrar la pantalla con importes que pueden ser incorrectos.

      Si hay un error en la función se devolverá en ocoderror y omsgerror

      La información del rescates se devuelve en un cursor.

******************************************************************************************/
   res        pk_cal_sini.valores%type;
   num_err    number;
   v_cursor   cursor_type;
   v_sproduc  number;
   mostrar_datos   number;
   v_frescate  date;

     CapGarant Number;
     Provision Number;
     fecIniEjerc Date;
     rendesejerc Number;
     rendesejercant Number;
     pctReduc Number;
     rendestrib Number;

begin
   -- Se valida que los parémetros de entrada vienen informados
   IF psseguro IS NULL THEN
      oCODERROR := 111995; -- Es obligatorio informar el número de seguro
      oMSGERROR := f_literal(oCODERROR, pcidioma_user);
      return v_cursor;
   END IF;

   IF pfrescate IS NULL THEN
      oCODERROR := 110740; -- Es necesario informar la fecha del siniestro.
      oMSGERROR := f_literal(oCODERROR, pcidioma_user);
      return v_cursor;
   END IF;

   IF pcidioma_user IS NULL THEN
      oCODERROR := 180522; -- Es obligatorio informar el idioma del usuario
      oMSGERROR := f_literal(oCODERROR, pcidioma_user);
      return v_cursor;
   END IF;

   v_frescate := trunc(pfrescate);
   mostrar_datos := 1;
   cavis := null;
   lavis := null;
   num_err := f_valida_permite_rescate_total(psseguro, pcagente, v_frescate, pcidioma_user,
      ocoderror, omsgerror);
   if num_err is null then
      return v_cursor;
   end if;

   num_err := pac_rescates.f_simulacion_rescate(psseguro, pcagente, 4, null, v_frescate, res);
   if num_err <> 0 then
      oCODERROR := num_err;
      oMSGERROR := f_literal(oCODERROR, pcidioma_user);
      rollback;
      return v_cursor;
   end if;

   num_err := pac_rescates.f_avisos_rescates(psseguro, v_frescate, res(1).isinret, cavis,
      mostrar_datos);

   if cavis is not null then
      lavis := f_literal(cavis, pcidioma_user);
   end if;
   -- Grabamos un registro en simulaestadist
   select sproduc into v_sproduc from seguros
   where sseguro = psseguro;
   num_err := pac_simul_comu.f_ins_simulaestadist(pcagente, v_sproduc, 3);
   IF num_err <> 0 THEN
      oCODERROR := num_err;
      oMSGERROR := f_literal(oCODERROR, pcidioma_user);
      rollback;
      return v_cursor;
   END IF;

  -- La función debe devolver la siguiente información:
  -- SPRODUC, CRAMO, CMODALI, CTIPSEG, CCOLECT, NPOLIZA, NCERTIF, CIDIOMA, FEFECTO, SPERSON1,
  -- SPERSON2, CSITUAC, TSITUAC, FVENCIM, CAPITAL_GARANTIZADO, CAPITAL COBERTURAS ADICIONALES,
  -- INTERÉS TÉCNICO, VALOR PROVISIÓN, IMPORTE PENALIZACIÓN, VALOR BRUTO RESCATE, PRIMAS SATISFECHAS,
  -- PLUSVALÍA, REDUCCIÓN, RED. DISP. TRANS, RCM, % RETENCIÓN, IMPORTE RETNECIÓN, VALOR RESATE NETO
  commit;




    CapGarant:=Pac_Provmat_Formul.F_CALCUL_FORMULAS_PROVI(psseguro, v_frescate, 'ICGARAC');
    Provision:=Pac_Provmat_Formul.F_CALCUL_FORMULAS_PROVI(psseguro, v_frescate, 'IPROVAC');

    fecIniEjerc:=TO_DATE('01/01/'||TO_CHAR(v_frescate,'YYYY'),'DD/MM/YYYY');



    select sum(decode(cmovimi,53,imovimi,10,-imovimi,imovimi))
    into rendesejercant
    from ctaseguro
    where sseguro=psseguro
    and cmovimi in (10,53)
    and nvl(cmovanu,0)=0
    and fvalmov<fecIniEjerc;

    select sum(decode(cmovimi,53,imovimi,10,-imovimi,imovimi))
    into rendesejerc
    from ctaseguro
    where sseguro=psseguro
    and cmovimi in (10,53)
    and nvl(cmovanu,0)=0
    and fvalmov>=fecIniEjerc;

    pctReduc:=Pk_rentas.F_BUSCAPRDUCCION(1, psseguro,TO_CHAR(v_frescate,'yyyymmdd'),2);



  open v_cursor for
      SELECT s.sproduc,
                   s.cramo,
                   s.cmodali,
                   s.ctipseg,
                   s.ccolect,
                   s.npoliza,
                   s.ncertif,
                   s.cidioma,
                  s.fefecto,
                  a.sperson sperson1,
                  a.ffecfin ffecfin1,
                  decode(a.ffecfin,null, null, decode(pcidioma_user, 1, 'Baja', 2, 'Baixa')) csit_aseg1,
                  a2.sperson sperson2,
                  a2.ffecfin ffecfin2,
                  decode(a2.ffecfin,null, null, decode(pcidioma_user, 1, 'Baja', 2, 'Baixa')) csit_aseg2,
                  s.csituac,
                  d.tatribu,
                  s.fvencim,
                  nvl(aho.NDURPER,s.NDURACI) per_garantit,
                  decode(mostrar_datos,1,ren.ICAPREN,null) prima_inicial,
                  decode(mostrar_datos,1,nvl(F_CAPGAR_ULT_ACT(s.sseguro, trunc(f_sysdate)),0),null) capGarant,--CapGarant capgarant,
                  decode(mostrar_datos,1,pac_inttec.ff_int_seguro('SEG', s.sseguro),null) inttec,
                  decode(mostrar_datos,1,pac_inttec.ff_int_seguro('SEG', s.sseguro),null) inttec2,
                  decode(mostrar_datos,1,Provision,null) Provision,
                  decode(mostrar_datos,1,res(1).ipenali,null) penali, --JRH IMP ? Es así.
                  decode(mostrar_datos,1,res(1).isinret,null) irescate, --JRH IMP ? Es así.
                  decode(mostrar_datos,1,pk_rentas.F_BUSCARENTABRUTA (1, psseguro, TO_CHAR(v_frescate,'yyyymmdd'),2),null) rentaBruta, --JRH IMP ? Es así.
                  decode(mostrar_datos,1,rendesejercant,null) rendesejercant,
                  decode(mostrar_datos,1,rendesejerc,null) rendesejerc,
                  decode(mostrar_datos,1,FBUSCAPRETEN(1, a.sperson,s.sproduc,TO_CHAR(v_frescate,'yyyymmdd'))*(1-pctReduc/100),null) CoefFor,
                  decode(mostrar_datos,1,rendestrib,null) rendestrib,--JRH IMP ?
                  decode(mostrar_datos,1,res(1).iresrcm, null) rcm,
                  decode(mostrar_datos,1,res(1).iretenc,null) retencion,
                  decode(mostrar_datos,1,res(1).iimpsin, null) iresneto

         /*decode(mostrar_datos,1,nvl(pac_calc_comu.ff_Capital_Gar_Tipo('SEG', s.SSEGURO, 1, 6, m.nmovimi, 1),0),null) cap_fallec,
         decode(mostrar_datos,1,nvl(pac_calc_comu.ff_Capital_Gar_Tipo('SEG', s.SSEGURO, 1, 7, m.nmovimi, 1),0),null) cap_accid,
         decode(mostrar_datos,1,res(1).icapris,null) capris,
         decode(mostrar_datos,1,res(1).iprimas, null) primas_cons,
         decode(mostrar_datos,1,(res(1).isinret - res(1).iprimas),null)rend_bruto,
         decode(mostrar_datos,1,res(1).iresred,null) reduccion,
         decode(mostrar_datos,1,(select sum(ireg_trans) from tmp_primas_consumidas where sseguro = psseguro),null) reg_trans,
         */

      from seguros s, asegurados a, detvalores d, movseguro m, asegurados a2,seguros_ren ren,seguros_aho aho
      where s.sseguro = a.sseguro
      and a.norden = 1
      and a2.sseguro (+) = s.sseguro
      and a2.norden (+) = 2
     -- LEFT JOIN asegurados a2 ON ( s.sseguro = a2.sseguro AND a2.norden = 2)
      and d.cvalor = 61 -- indicador situación póliza
      and d.cidioma = pcidioma_user
      and d.catribu = s.csituac
      and m.sseguro = s.sseguro
      and m.nmovimi = (select max(nmovimi) from movseguro where sseguro = s.sseguro)
      and ren.sseguro=s.sseguro
      and aho.sseguro=s.sseguro
      and s.sseguro = psseguro;

      RETURN v_cursor;

EXCEPTION
   WHEN OTHERS THEN
      ocoderror := 180561;  -- Error General
      omsgerror := f_literal(ocoderror, pcidioma_user);
      p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Sinies_Ren.f_sim_rescate_total',NULL,
        'parametros: psseguro='||psseguro||' pcagente='||pcagente||' pfrescate ='||pfrescate,
        SQLERRM);
      close v_cursor;
      rollback;
      RETURN v_cursor;

end f_sim_rescate_total;



FUNCTION f_sol_rescate_total(psseguro in number, pcagente in number, pfrescate in date,
   pcidioma in number, pcidioma_user in number,  pirescate in number, oCODERROR OUT NUMBER, oMSGERROR OUT VARCHAR2,
   pccausin NUMBER DEFAULT 4)
  RETURN  number is
/**************************************************************************
   Función para solicitar un rescate total.
   Pnivel: 1.- Se generan todos los datos posibles: valoraciones, destinatarios y pagos
           2.- No se generarán pagos
   Pccausin: default 4 (rescate total) pero al tener el parámetro podemos utilizar
      la función para solicitar un vencimiento (pccausin = 3)
********************************************************************************/
   v_sproduc   number;
   num_err   number;
   xnivel   number;
   cavis    number;
   pdatos   number;
   v_frescate  date;
begin

   return(Pac_Ref_Sinies_Aho.f_sol_rescate_total(psseguro, pcagente, pfrescate, pcidioma, pcidioma_user,
                                                                                  pirescate, oCODERROR, oMSGERROR,pccausin));

exception
   WHEN OTHERS THEN
        oCODERROR := -999;
        oMSGERROR := 'Pac_Ref_Sinies_Ren.f_sol_rescate_total: Error general en la función';
        p_tab_error(f_sysdate,  F_USER,  'Pac_Ref_Sinies_Ren.f_sim_rescate_total',NULL,
                    'parametros: psseguro = '||psseguro||'  pcagente = '||pcagente||
                    'pfrescate = '||pfrescate, SQLERRM);
        Rollback;
        return null;
end f_sol_rescate_total;



END Pac_Ref_Sinies_Ren;

/

  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_REN" TO "R_AXIS";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_REN" TO "PROGRAMADORESCSI";
  GRANT EXECUTE ON "AXIS"."PAC_REF_SINIES_REN" TO "CONF_DWH";
