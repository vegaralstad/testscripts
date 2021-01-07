#!/bin/bash


EXTRACTS="Customers CustomerNotes AppointmentNotes Refracted Prescription Dispense OutsideRx HabitualRx ObjectiveAndIOP SightTest"
#-------------------------------------------------------
# Customers:
#
HEADER_ROW[1]="Customer ID~First Name~Last Name~Status~DOB~Gender~Last Test~Address~Home Phone~Work Phone~Mobile Phone~Email~Other"
SQL[1]="select c.customer_id,
n.first_name,
n.last_name,
c.status,
ifnull(date(c.date_of_birth),'') as date_of_birth,
g.description,
ifnull(c.last_test,''),
CONCAT_WS(' ',ifnull(a.address_line1,''), ifnull(a.address_line2,''), ifnull(a.district,''), ifnull(a.town,''), ifnull(a.county,''), ifnull(a.post_code,''), ifnull(a.country,'')),
ifnull((select  concat(cd.stdcode,cd.detail) from contact_detail cd, customer_contact_detail ccd where ccd.customer_id = c.customer_id and cd.contact_detail_id = ccd.contact_detail_id and cd.contact_type_id=1 limit 1),'') as home_phone,
ifnull((select  concat(cd.stdcode,cd.detail) from contact_detail cd, customer_contact_detail ccd where ccd.customer_id = c.customer_id and cd.contact_detail_id = ccd.contact_detail_id and cd.contact_type_id=2 limit 1),'') as work_phone,
ifnull((select  concat(cd.stdcode,cd.detail) from contact_detail cd, customer_contact_detail ccd where ccd.customer_id = c.customer_id and cd.contact_detail_id = ccd.contact_detail_id and cd.contact_type_id=3 limit 1),'') as mobile_phone,
ifnull((select  cd.detail from contact_detail cd, customer_contact_detail ccd where ccd.customer_id = c.customer_id and cd.contact_detail_id = ccd.contact_detail_id and cd.contact_type_id=4 limit 1),'') as email,
ifnull((select  cd.detail from contact_detail cd, customer_contact_detail ccd where ccd.customer_id = c.customer_id and cd.contact_detail_id = ccd.contact_detail_id and cd.contact_type_id=5 limit 1),'') as other

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from customer c
inner join name n on c.name_id = n.name_id
inner join gender g on c.gender_id = g.gender_id
left outer join customer_address ca on c.customer_id = ca.customer_id
left outer join address a on ca.address_id = a.address_id
left outer join customer_contact_detail ccd on c.customer_id = ccd.customer_id
left outer join contact_detail cd on ccd.contact_detail_id = cd.contact_detail_id
group by c.customer_id
order by c.customer_id"

#-------------------------------------------------------
# Customer Notes
#
HEADER_ROW[2]="Customer ID~First Name~Last Name~Date~Short Note~Long Note"
SQL[2]="select c.customer_id,
na.first_name,
na.last_name,
n.creation_date,
n.short_note,
REPLACE(n.long_note,'\n','   ')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from customer c
inner join notes n on c.customer_id = n.customer_id
inner join name na on c.name_id = na.name_id
order by c.customer_id"

#-------------------------------------------------------
# Appointment Notes
#
HEADER_ROW[3]="Customer ID~First Name~Last Name~Date~Status~Short Note~Long Note"

SQL[3]="select a.customer_id,
na.first_name,
na.last_name,
a.date,
a.status,
n.short_note,
REPLACE(n.long_note,'\n','   ')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from notes n
left outer join appointment a on n.appointment_id = a.appointment_id
left outer join customer c on a.customer_id = c.customer_id
left outer join name na on c.name_id = na.name_id
where n.appointment_id is not null
order by a.customer_id,a.date"


#-------------------------------------------------------
# Appointments
#
#HEADER_ROW[3]="Customer ID~ First Name~ Last Name~ Date~ Status~ Type~ Staff Member"
#SQL[3]="select a.customer_id,
#a.date,
#a.status,
#ast.description,
#CONCAT_WS(' ', n.first_name, n.last_name)
#
#INTO OUTFILE '/tmp/partnerExtract.txt'
#FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'
#
#from appointment a
#inner join appointment_sub_type ast on a.appointment_sub_type_id = ast.appointment_sub_type_id
#inner join staff s on a.staff_id = s.staff_id
#inner join name n on s.name_id = n.name_id
#order by customer_id"

#-------------------------------------------------------
# 
# Refraction data - Refracted Rx
HEADER_ROW[4]="Customer ID~First Name~Last Name~TR Number~Status~Date~Optometrist~Vision R~Vision L~BIN Vision~Sph R~Sph L~Cyl R~Cyl L~Axis R~Axis L~Near Add R~ Near Add L~Inter Add R~Inter Add L~Dist VA R~Dist VA L~Dist Bin VA~Near VA R~Near VA L~PD R~PD L~BVD~H Prisms Distance R~H Prisms Distance L~V Prisms Distance R~V Prisms Distance L~H Prisms Near R~H Prisms Near L~V Prisms Near R~V Prisms Near L~Notes~Specific Add R~Specific Add L~Current Specs VA R~Current Specs VA L"

SQL[4]="select rec.customer_id,
n.first_name,
n.last_name,
st.tr_number,
st.status,
rec.customer_arrival_time,
ifnull((select CONCAT_WS(' ',na.first_name,na.last_name) from name na, staff sta where sta.name_id = na.name_id and sta.staff_id = st.staff_id),''),
ifnull(rx.vision_right_as_string,'') as vision_r, 
ifnull(rx.vision_left_as_string,'') as vision_l, 
ifnull(rx.bin_vision_as_string,''), 
ifnull(rx.sph_right_as_string,''), 
ifnull(rx.sph_left_as_string,''), 
ifnull(rx.cyl_right_as_string,''), 
ifnull(rx.cyl_left_as_string,''), 
ifnull(rx.axis_right,''), 
ifnull(rx.axis_left,''), 
ifnull(rx.near_add_right,''), 
ifnull(rx.near_add_left,''), 
ifnull(rx.inter_add_right,''), 
ifnull(rx.inter_add_left,''), 
ifnull(rx.dist_va_right_as_string,'') as dist_va_right, 
ifnull(rx.dist_va_left_as_string,'') as dist_va_l, 
ifnull(rx.dist_bin_va_as_string,'') as dist_bin_va, 
ifnull(rx.near_va_right_as_string,'') as near_va_r, 
ifnull(rx.near_va_left_as_string,'') as near_va_l, 
ifnull(rx.pd_right,''), 
ifnull(rx.pd_left,''), 
ifnull(rx.bvd,''), 
ifnull(rx.prism_distance_horizontal_right_as_string,'') as h_prism_distance_r, 
ifnull(rx.prism_distance_horizontal_left_as_string,'') as h_prism_distance_l, 
ifnull(rx.prism_distance_vertical_right_as_string,'') as v_prism_distance_r, 
ifnull(rx.prism_distance_vertical_left_as_string,'') as v_prism_distance_l, 
ifnull(rx.prism_near_horizontal_right_as_string,'') as h_prism_near_r, 
ifnull(rx.prism_near_horizontal_left_as_string,'') as h_prism_near_l, 
ifnull(rx.prism_near_vertical_right_as_string,'') as v_prism_near_r, 
ifnull(rx.prism_near_vertical_left_as_string,'') as v_prism_near_l, 
ifnull(rx.notes,''),
ifnull(prx.specific_add_right,''),
ifnull(prx.specific_add_left,''),
ifnull(prx.specific_add_reason,''),
ifnull(prx.current_specs_va_right_as_string,''),
ifnull(prx.current_specs_va_left_as_string,'')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from rx rx
inner join refracted_rx prx on prx.rx_id = rx.rx_id
inner join sight_test st on prx.refracted_rx_id = st.refracted_rx_id 
inner join record rec on st.tr_number = rec.record_id
inner join customer c on rec.customer_id = c.customer_id
inner join name n on n.name_id = c.name_id
left outer join staff s on st.staff_id = s.staff_id
order by rec.customer_id, st.refracted_rx_id"

#-------------------------------------------------------
# 
# Prescription for glasses - Prescribed Rx:

HEADER_ROW[5]="Customer ID~First Name~Last Name~TR Number~Status~Staff~Date~Vision R~Vision L~BIN Vision~Sph R~Sph L~Cyl R~Cyl L~Axis R~Axis L~Near Add R~ Near Add L~Inter Add R~Inter Add L~Dist VA R~Dist VA L~Dist Bin VA~Near VA R~Near VA L~PD R~PD L~BVD~H Prisms Distance R~H Prisms Distance L~V Prisms Distance R~V Prisms Distance L~H Prisms Near R~H Prisms Near R~V Prisms Near R~V Prisms Near L~Notes"
SQL[5]="select rec.customer_id,
n.first_name,
n.last_name,
st.tr_number,
st.status,
if (st.staff_id <> null, (select CONCAT(' ', na.first_name, na.last_name) from name na where na.name_id = (select sta.name_id from staff sta where sta.staff_id = st.staff_id)),'') as  staff,
rec.customer_arrival_time,
ifnull(rx.vision_right_as_string,'') as vision_r, 
ifnull(rx.vision_left_as_string,'') as vision_l, 
ifnull(rx.bin_vision_as_string,''), 
ifnull(rx.sph_right_as_string,''), 
ifnull(rx.sph_left_as_string,''), 
ifnull(rx.cyl_right_as_string,''), 
ifnull(rx.cyl_left_as_string,''), 
ifnull(rx.axis_right,''), 
ifnull(rx.axis_left,''), 
ifnull(rx.near_add_right,''), 
ifnull(rx.near_add_left,''), 
ifnull(rx.inter_add_right,''), 
ifnull(rx.inter_add_left,''), 
ifnull(rx.dist_va_right_as_string,'') as dist_va_right, 
ifnull(rx.dist_va_left_as_string,'') as dist_va_l, 
ifnull(rx.dist_bin_va_as_string,'') as dist_bin_va, 
ifnull(rx.near_va_right_as_string,'') as near_va_r, 
ifnull(rx.near_va_left_as_string,'') as near_va_l, 
ifnull(rx.pd_right,''), 
ifnull(rx.pd_left,''), 
ifnull(rx.bvd,''), 
ifnull(rx.prism_distance_horizontal_right_as_string,'') as h_prism_distance_r, 
ifnull(rx.prism_distance_horizontal_left_as_string,'') as h_prism_distance_l, 
ifnull(rx.prism_distance_vertical_right_as_string,'') as v_prism_distance_r, 
ifnull(rx.prism_distance_vertical_left_as_string,'') as v_prism_distance_l, 
ifnull(rx.prism_near_horizontal_right_as_string,'') as h_prism_near_r, 
ifnull(rx.prism_near_horizontal_left_as_string,'') as h_prism_near_l, 
ifnull(rx.prism_near_vertical_right_as_string,'') as v_prism_near_r, 
ifnull(rx.prism_near_vertical_left_as_string,'') as v_prism_near_l, 
ifnull(rx.notes,'')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from rx rx, 
prescribed_rx prx, 
sight_test st, 
record rec,
customer c,
name n

where rx.rx_id = prx.rx_id 
and st.prescribed_rx_id = prx.prescribed_rx_id 
and rec.record_id=st.tr_number 
and rec.customer_id=c.customer_id
and c.name_id=n.name_id
order by rec.customer_id, st.prescribed_rx_id"

#-------------------------------------------------------
# 
#Dispensed Rx
#Glasses manufactured, including lens powers, fitting parameters and lens type/product name

HEADER_ROW[6]="Customer ID~First Name~Last Name~TR Number~Status~Collection Date~Type of Order~Frame Sku~Frame~Lens Sku R~Lens Sku L~Lens Name R~Lens Name L~Dia R~Dia L~Lens Type R~Lens Type L~Dispense Type R~Dispense Type L~Sph R~Sph L~Cyl R~Cyl L~Axis R~Axis L~Add R~Add L~H Prism R~H Prism L~V Prism R~V Prism L~OCS R~OCS L~Heights R~Heights L~Height Dir R~Height Dir L~Inset R~Inset L~Back Vertex R~Back Vertex L~Reason for change~Notes~Advice"
SQL[6]="select cdo.customer_id,
n.first_name,
n.last_name,
ifnull(st.tr_number,''),
ifnull(st.status,''),
di.collection_date,
ifnull(dr.dispense_item_type,'') as  type_of_order,
ifnull(p.sku,''),
ifnull(p.short_name,''),
ifnull(di.right_lens_sku,''),
ifnull(di.left_lens_sku,''),
ifnull(lbr.description,'') as lens_desc_r,
ifnull(lbl.description,'') as lens_desc_l,
ifnull(di.right_dia,''),
ifnull(di.left_dia,''),
ifnull(di.right_lens_type,''),
ifnull(di.left_lens_type,''),
ifnull(dr.dispense_type_right,''),
ifnull(dr.dispense_type_left,''),
ifnull(dr.sph_right_as_string,''), 
ifnull(dr.sph_left_as_string,''), 
ifnull(dr.cyl_right_as_string,''), 
ifnull(dr.cyl_left_as_string,''), 
ifnull(dr.axis_right,''), 
ifnull(dr.axis_left,''), 
ifnull(dr.add_right,''), 
ifnull(dr.add_left,''), 
ifnull(dr.prism_horizontal_right_as_string,'') as h_prism_r,
ifnull(dr.prism_horizontal_left_as_string,'') as h_prism_l, 
ifnull(dr.prism_vertical_right_as_string,'') as v_prism_r, 
ifnull(dr.prism_vertical_left_as_string,'') as v_prism_l,
ifnull(dr.ocs_right,''), 
ifnull(dr.ocs_left,''),
ifnull(dr.heights_right,''), 
ifnull(dr.heights_left,''),
ifnull(dr.height_direction_right,''), 
ifnull(dr.height_direction_left,''),
ifnull(dr.insets_right,''), 
ifnull(dr.insets_left,''),
ifnull(dr.back_vertex_right,''), 
ifnull(dr.back_vertex_left,''),
if(dr.reason_for_change is null or dr.reason_for_change = 'Migrated (UK3)','',dr.reason_for_change),
ifnull(st.dispense_notes,''),
ifnull(st.advice,'')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from clinical_dispense_order cdo
inner join customer c on cdo.customer_id = c.customer_id
inner join name n on n.name_id = c.name_id
inner join dispense_item di on cdo.clinical_dispense_order_id = di.clinical_dispense_order_id
inner join dispense_rx dr on di.dispense_item_id = dr.dispense_rx_id 
left outer join product p on di.frame_sku = p.sku
left outer join sight_test st on cdo.sight_test_id = st.sight_test_id

left join (select spectacle_lens_product_id, lab_code, description
from lab_code l
) as lbr on lbr.spectacle_lens_product_id=di.left_lens_sku and lbr.lab_code=di.left_lens_product_code

left join (select spectacle_lens_product_id, lab_code, description
from lab_code l 
) as lbl on lbl.spectacle_lens_product_id=di.left_lens_sku and lbl.lab_code=di.left_lens_product_code 

where di.status = 'COLLECTED' OR di.status = 'TO_BE_COLLECTED' OR di.status = 'TRANSMITTED'
AND cdo.order_state != 'SUSPENDED'
order by cdo.customer_id"

#-------------------------------------------------------
# 
#Outside Rx

HEADER_ROW[7]="Customer ID~First Name~Last Name~Test Date~Sph R~Sph L~Cyl R~Cyl L~Axis R~Axis L~Near Add R~ Near Add L~Inter Add R~Inter Add L~BVD~H Prisms Distance R~H Prisms Distance L~V Prisms Distance R~V Prisms Distance L~H Prisms Near R~H Prisms Near L~V Prisms Near R~V Prisms Near L~Written Verification~Phone Verification~Outside Optician Branch~Outside Optician Name~Outside Optician Goc Num~Outside Optician Recom~Outside Optician Notes"
SQL[7]="select o.customer_id,
n.first_name,
n.last_name,
o.test_date,
ifnull(o.sph_right_as_string,''), 
ifnull(o.sph_left_as_string,''),
ifnull(o.cyl_right_as_string,''), 
ifnull(o.cyl_left_as_string,''), 
ifnull(o.axis_right,''), 
ifnull(o.axis_left,''), 
ifnull(o.near_add_right,''), 
ifnull(o.near_add_left,''), 
ifnull(o.inter_add_right,''), 
ifnull(o.inter_add_left,''),
ifnull(o.bvd,''),
ifnull(o.prism_distance_horizontal_right_as_string,'') as h_prism_distance_r, 
ifnull(o.prism_distance_horizontal_left_as_string,'') as h_prism_distance_l, 
ifnull(o.prism_distance_vertical_right_as_string,'') as v_prism_distance_r, 
ifnull(o.prism_distance_vertical_left_as_string,'') as v_prism_distance_l, 
ifnull(o.prism_near_horizontal_right_as_string,'') as h_prism_near_r, 
ifnull(o.prism_near_horizontal_left_as_string,'') as h_prism_near_l, 
ifnull(o.prism_near_vertical_right_as_string,'') as v_prism_near_r,
ifnull(o.prism_near_vertical_left_as_string,'') as v_prism_near_l, 
ifnull(o.written_verification,''),
ifnull(o.phone_verification,''),
if(oo.branch <> null or oo.branch = 'Migrated Branch','',oo.branch),
if(oo.optician_name <> null or oo.optician_name = 'Migrated Optician Name','',oo.optician_name),
ifnull(oo.gocnumber,''),
ifnull(oo.recommendation,''),
ifnull(oo.notes,'')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from outside_spec_rx o
inner join customer c on o.customer_id = c.customer_id
inner join name n on n.name_id = c.name_id
inner join outside_optician oo on o.outside_optician_id = oo.outside_optician_id
order by o.customer_id"

#-------------------------------------------------------
# 
#Habitual Rx

HEADER_ROW[8]="Customer ID~First Name~Last Name~TR Number~Status~Test Date~Sph R~Sph L~Cyl R~Cyl L~Axis R~Axis L~H Prism R~H Prism L~V Prism R~V Prism L~Add R~Add L~OC R~OC L~Var R~Var L~Notes~Specs Age~Optician~Pair Number"
SQL[8]="select r.customer_id,
n.first_name,
n.last_name,
ifnull(s.tr_number,''),
ifnull(s.status,''),
r.customer_arrival_time,
ifnull(o.sph_right,''), 
ifnull(o.sph_left,''),
ifnull(o.cyl_right,''), 
ifnull(o.cyl_left,''), 
ifnull(o.axis_right,''), 
ifnull(o.axis_left,''), 
ifnull(o.prism_horizontal_right,''), 
ifnull(o.prism_horizontal_left,''), 
ifnull(o.prism_vertical_right,''), 
ifnull(o.prism_vertical_left,''), 
ifnull(o.add_right,''), 
ifnull(o.add_left,''), 
ifnull(o.ocright,''), 
ifnull(o.ocleft,''), 
ifnull(o.varight,''), 
ifnull(o.valeft,''), 
ifnull(o.notes,''),
ifnull(o.specs_age,''),
ifnull(o.optician,''),
ifnull(o.pair_number,'')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from specs o
inner join sight_test s on o.habitual_rx_id = s.habitual_rx_id
inner join record r on s.tr_number = r.record_id
inner join customer c on r.customer_id = c.customer_id
inner join name n on n.name_id = c.name_id
order by r.customer_id"

#-------------------------------------------------------
# 
#Objective And IOP

HEADER_ROW[9]="Customer ID~First Name~Last Name~Sight Test ID~Arrival Date~Sph R~Sph L~Cyl R~Cyl L~IOP1 R~IOP1 L~IOP2 R~IOP2 L~IOP3 R~IOP3 L~IOP4 R~IOP4 L~IOP Time~Axis R~Axis L~VA R~VA L~Notes~Drug Info"
SQL[9]="select r.customer_id,
n.first_name,
n.last_name,
s.sight_test_id,
r.customer_arrival_time,
ifnull(o.sph_right_as_string,''), 
ifnull(o.sph_left_as_string,''),
ifnull(o.cyl_right_as_string,''), 
ifnull(o.cyl_left_as_string,''), 
ifnull(o.iopone_right_as_string,''), 
ifnull(o.iopone_left_as_string,''), 
ifnull(o.ioptwo_right_as_string,''), 
ifnull(o.ioptwo_left_as_string,''), 
ifnull(o.iopthree_right_as_string,''), 
ifnull(o.iopthree_left_as_string,''), 
ifnull(o.iopfour_right_as_string,''), 
ifnull(o.iopfour_left_as_string,''), 
ifnull(o.ioptime,''), 
ifnull(o.axis_right,''), 
ifnull(o.axis_left,''),
ifnull(o.va_right_as_string,''), 
ifnull(o.va_left_as_string,''),
ifnull(o.notes,''),
ifnull(o.drug_info,'')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from objective_and_iop o
inner join sight_test s on o. objective_and_iop_id = s. objective_and_iop_id
inner join record r on s.tr_number = r.record_id
inner join customer c on r.customer_id = c.customer_id
inner join name n on n.name_id = c.name_id
order by r.customer_id"


#-------------------------------------------------------
# 
# Sight Tests

HEADER_ROW[10]="Customer ID~First Name~Last Name~TR Number~Status~Staff~Status~Arrival Date~Reason for Visit~General Health~Medication~Ocular History~Family History~VDU~Hours Per Day~Hobbies~Occupation~Heavy Goods Driver~Private Driver~Public Services Driver~Motorcycle Drvier~Time of Dilation~Drugs Used~Batch No~Expiry Date~Pressure Predilation~Time of Pressure Reading PredilationDirect~Indirect~Volk~Dilated~Slit Lamp"

SQL[10]="select r.customer_id,
n.first_name,
n.last_name,
s.tr_number,
s.status,
if (s.staff_id <> null, (select CONCAT(' ', na.first_name, na.last_name) from name na where na.name_id = (select sta.name_id from staff sta where sta.staff_id = s.staff_id)),'') as  staff,
r.customer_arrival_time,
ifnull(sy.reason_for_visit_notes,''),
ifnull(sy.general_health_notes,''),
ifnull(sy.medication_notes,''),
ifnull(sy.ocular_history_notes,''),
ifnull(sy.family_history_notes,''),
ifnull(ls.visual_display_unit,'') as vdu,
ifnull(ls.hours_per_day,''),
ifnull(ls.hobbies,''),
ifnull(ls.occupation,''),
ifnull(da.heavy_goods,'') as driver,
ifnull(da.private,'') as driver_private,
ifnull(da.public_services,'') as driver_public_services,
ifnull(da.motorcycle,'') as driver_motorcycle,
ifnull(ct.timeofdilation,''),
ifnull(ct.drugused,''),
ifnull(ct.batchno,''),
ifnull(ct.expirydate,''),
ifnull(ct.pressurepredilation,''),
ifnull(ct.timeofpressurereadingpredilation,''),
ifnull(ct.direct,''),
ifnull(ct.indirect,''),
ifnull(ct.volk,''),
ifnull(ct.dilated,''),
ifnull(ct.slitlamp,'')

INTO OUTFILE '/tmp/partnerExtract.txt'
FIELDS TERMINATED BY '~' OPTIONALLY ENCLOSED BY '\"'

from sight_test s
left outer join symptom sy on s.symptom_id = sy.symptom_id
left outer join life_style ls on s.life_style_id = ls.life_style_id
left outer join sight_test_driver_answer da on s. sight_test_driver_answers_id = da. sight_test_driver_answers_id
left outer join clinical_test_conditions ct on s.clinical_test_conditions_id = ct.clinical_test_condition_id
inner join record r on s.tr_number = r.record_id
inner join customer c on r.customer_id = c.customer_id
inner join name n on n.name_id = c.name_id
order by r.customer_id"

