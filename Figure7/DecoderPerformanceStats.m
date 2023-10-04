
% Statistical tests - unpaired t-test on square root transformed data (to achieve normality)
p_vals = nan(1,3);
[~,p_vals(1)] = kstest2(sqrt(carryLengthStim(carryTimeStim>3)),sqrt(carryLengthNoStim(carryTimeNoStim>3)));
[~, p_vals(2)] = kstest2(carryLengthBio(carryTimeBio>3),carryLengthStim(carryTimeStim>3));
[~,p_vals(3)] = kstest2(sqrt(carryLengthBio(carryTimeBio>3)),sqrt(carryLengthNoStim(carryTimeNoStim>3)));
