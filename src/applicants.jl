struct Applicant
    id::Int
    name::String
    country::String
end

name(applicant::Applicant) = applicant.name
country(applicant::Applicant) = applicant.country
