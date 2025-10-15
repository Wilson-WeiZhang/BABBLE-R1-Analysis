%% ========================================================================
%  STEP 0: A Priori Power Analysis - Sample Size Estimation
%  ========================================================================
%
%  PURPOSE:
%  Calculate required sample size for detecting learning effects based on
%  effect sizes from previous infant word learning studies.
%
%  CORRESPONDS TO MANUSCRIPT:
%  - Methods Section 4.1 (Participants)
%  - "A-priori power calculation (for t-test analysis) indicated that
%    N=45 participants would be required to achieve a statistical power
%    of 0.8 at an alpha level of 0.05"
%
%  ANALYSIS PARAMETERS:
%  - Effect size: d = 0.43 (Cohen's d from Saffran et al., 1996)
%  - Significance level: α = 0.05 (two-tailed)
%  - Desired power: 0.80 (80% power)
%  - Test type: One-sample t-test (comparing looking times)
%
%  METHOD:
%  - Iterative approach accounting for degrees of freedom
%  - Uses t-distribution critical values (not z-approximation)
%  - Converges when sample size estimate stabilizes
%
%  RESULT:
%  - Required N = 45 participants
%  - Actual study recruited N = 47 participants (29 UK, 18 SG)
%
%  REFERENCE:
%  Saffran, J.R., Aslin, R.N., & Newport, E.L. (1996). Statistical
%  Learning by 8-Month-Old Infants. Science, 274, 1926-1928.
%
%  ========================================================================

% Parameters
d = 0.43;       % Cohen's d effect size from previous study
alpha = 0.05;   % Significance level
power = 0.80;   % Desired power

% Calculate non-centrality parameter
ncp = 0;
n_estimate = 10; % Initial guess
converged = false;

while ~converged
    % Update degrees of freedom
    df = n_estimate - 1;
    
    % Critical t-value for alpha
    t_crit = tinv(1-alpha/2, df);
    
    % Calculate required sample size
    n_new = ceil((t_crit + norminv(power))^2 / d^2);
    
    if abs(n_new - n_estimate) < 1
        converged = true;
    else
        n_estimate = n_new;
    end
end

fprintf('Required sample size: %d\n', n_estimate);
% 
% %% or 
% % Iterative power analysis for one-sample t-test
% % Parameters
% d = 0.43;          % Cohen's d effect size from previous study
% alpha = 0.05;      % Significance level
% power = 0.80;      % Desired power
% 
% % Iterative approach to find sample size
% n_estimate = 10;   % Initial guess
% converged = false;
% iterations = 0;    % Track iterations for safety
% 
% fprintf('Iteration\tEstimate\tDegrees of Freedom\tCritical t\tNew Estimate\n');
% fprintf('-----------------------------------------------------------------\n');
% 
% while ~converged && iterations < 100
%     iterations = iterations + 1;
% 
%     % Update degrees of freedom
%     df = n_estimate - 1;
% 
%     % Critical t-value for alpha (two-sided test)
%     t_crit = tinv(1-alpha/2, df);
% 
%     % Calculate required sample size
%     n_new = ceil((t_crit + norminv(power))^2 / d^2);
% 
%     fprintf('%d\t\t%d\t\t%d\t\t\t%.4f\t\t%d\n', ...
%             iterations, n_estimate, df, t_crit, n_new);
% 
%     if abs(n_new - n_estimate) < 1
%         converged = true;
%     else
%         n_estimate = n_new;
%     end
% end
% 
% if converged
%     fprintf('\nConverged! Required sample size: %d\n', n_estimate);
% else
%     fprintf('\nDid not converge after %d iterations.\n', iterations);
% end
% 
% % For comparison, calculate with the simpler z-approximation method
% z_alpha = norminv(1-alpha/2);
% z_beta = norminv(power);
% n_z_approx = ceil((z_alpha + z_beta)^2 / d^2);
% 
% fprintf('\nFor comparison:\n');
% fprintf('Sample size using z-approximation (no iteration): %d\n', n_z_approx);