select *
  from uni.student;

select stufname,
       to_char(
           studob,
           'dd-mm-yyyy'
       ) as dob
  from uni.student
 where studob > to_date('01-01-1992','dd-mm-yyyy');

select *
  from uni.student
 where stufname = 'shadow'; --Case sensitive

 
select *
  from uni.student
 where upper(stufname) = upper('shadow');