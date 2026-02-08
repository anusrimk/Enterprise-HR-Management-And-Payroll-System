import * as dashboardService from "../services/dashboard.service.js";

export const getOverview = async (req, res) => {
  const data = await dashboardService.getOverview();
  res.json(data);
};
