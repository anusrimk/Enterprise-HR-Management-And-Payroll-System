/**
 * Calculate payroll from salary, working days and present days.
 * @param {number} salary - Monthly salary
 * @param {number} workingDays - Working days in the month (e.g. 22)
 * @param {number} presentDays - Days employee was present
 * @returns {{ perDaySalary: number, payableSalary: number }}
 */
export const calculatePayroll = (salary, workingDays, presentDays) => {
  if (!workingDays || workingDays <= 0) {
    return { perDaySalary: 0, payableSalary: 0 };
  }
  const perDaySalary = salary / workingDays;
  const payableSalary = perDaySalary * Math.max(0, presentDays);
  return {
    perDaySalary: Math.round(perDaySalary * 100) / 100,
    payableSalary: Math.round(payableSalary * 100) / 100,
  };
};
