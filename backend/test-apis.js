/**
 * Run: node test-apis.js
 * Starts the server on a random port, runs all API tests, then exits.
 */
import "dotenv/config";

import http from "http";
import connectDB from "./src/config/db.js";
import app from "./src/app.js";

let server;
let BASE;

async function request(method, url, body = null) {
  const opts = {
    method,
    headers: { "Content-Type": "application/json" },
  };
  if (body) {
    opts.body = JSON.stringify(body);
  }
  const res = await fetch(url, opts);
  const text = await res.text();
  let data = null;
  try {
    data = text ? JSON.parse(text) : null;
  } catch (_) {}
  return { status: res.status, data, text };
}

async function run() {
  await connectDB();

  server = http.createServer(app);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  const port = server.address().port;
  BASE = `http://127.0.0.1:${port}`;

  let createdEmployeeId = null;
  let createdLeaveId = null;
  const results = [];

  console.log(
    "=== API Tests (base: " + BASE + ", port: " + server.address().port + ")\n",
  );

  let r;
  const uniqueEmail = "apitest-" + Date.now() + "@example.com";

  // create employee
  r = await request("POST", BASE + "/api/employees", {
    name: "API Test User",
    email: uniqueEmail,
    department: "IT",
    designation: "Developer",
    joiningDate: "2025-01-01",
    salary: 50000,
  });
  createdEmployeeId = r.data?.employee?._id || r.data?._id;
  results.push({
    name: "POST /api/employees",
    ok: r.status === 200 && createdEmployeeId,
    status: r.status,
  });

  // list employees
  r = await request("GET", BASE + "/api/employees");
  results.push({
    name: "GET /api/employees",
    ok: r.status === 200 && Array.isArray(r.data),
    status: r.status,
  });

  // get employee
  if (createdEmployeeId) {
    r = await request("GET", BASE + "/api/employees/" + createdEmployeeId);
    results.push({
      name: "GET /api/employees/:id",
      ok: r.status === 200 && r.data?.name === "API Test User",
      status: r.status,
    });
  } else {
    results.push({ name: "GET /api/employees/:id", ok: false, status: 0 });
  }

  // invalid employee
  r = await request("GET", BASE + "/api/employees/000000000000000000000000");
  results.push({
    name: "GET /api/employees/:id (invalid)",
    ok: r.status === 404 || r.status === 500,
    status: r.status,
  });

  // mark attendance
  if (createdEmployeeId) {
    r = await request("POST", BASE + "/api/attendance/mark", {
      employeeId: createdEmployeeId,
      date: new Date().toISOString(),
      status: "PRESENT",
    });
    results.push({
      name: "POST /api/attendance/mark",
      ok: r.status === 200 && (r.data?.attendance || r.data?._id),
      status: r.status,
    });

    // get attendance
    r = await request("GET", BASE + "/api/attendance/" + createdEmployeeId);
    results.push({
      name: "GET /api/attendance/:employeeId",
      ok: r.status === 200 && Array.isArray(r.data),
      status: r.status,
    });

    // generate payroll
    r = await request("POST", BASE + "/api/payroll/generate", {
      employeeId: createdEmployeeId,
      month: 2,
      year: 2025,
    });
    results.push({
      name: "POST /api/payroll/generate",
      ok: r.status === 200 && (r.data?.payroll || r.data?._id),
      status: r.status,
    });

    // get payroll
    r = await request("GET", BASE + "/api/payroll/" + createdEmployeeId);
    results.push({
      name: "GET /api/payroll/:employeeId",
      ok: r.status === 200 && Array.isArray(r.data),
      status: r.status,
    });

    // create leave
    r = await request("POST", BASE + "/api/leaves", {
      employeeId: createdEmployeeId,
      leaveType: "CASUAL",
      startDate: "2025-02-10",
      endDate: "2025-02-11",
      days: 2,
      reason: "Personal",
    });
    createdLeaveId = r.data?.leave?._id || r.data?._id;
    results.push({
      name: "POST /api/leaves",
      ok: r.status === 200 && createdLeaveId,
      status: r.status,
    });

    // list leaves
    r = await request("GET", BASE + "/api/leaves");
    results.push({
      name: "GET /api/leaves",
      ok: r.status === 200 && Array.isArray(r.data),
      status: r.status,
    });

    // get leaves by employee
    r = await request(
      "GET",
      BASE + "/api/leaves/employee/" + createdEmployeeId,
    );
    results.push({
      name: "GET /api/leaves/employee/:employeeId",
      ok: r.status === 200 && Array.isArray(r.data),
      status: r.status,
    });

    // get leave by id
    if (createdLeaveId) {
      r = await request("GET", BASE + "/api/leaves/" + createdLeaveId);
      results.push({
        name: "GET /api/leaves/:id",
        ok: r.status === 200 && r.data?._id,
        status: r.status,
      });

      // update leave
      r = await request("PUT", BASE + "/api/leaves/" + createdLeaveId, {
        status: "APPROVED",
      });
      results.push({
        name: "PUT /api/leaves/:id",
        ok: r.status === 200 && r.data?.status === "APPROVED",
        status: r.status,
      });
    }
  }

  // dashboard overview
  r = await request("GET", BASE + "/api/dashboard/overview");
  results.push({
    name: "GET /api/dashboard/overview",
    ok: r.status === 200 && typeof r.data?.totalEmployees === "number",
    status: r.status,
  });

  console.log("Result per API:");
  results.forEach(({ name, ok, status }) => {
    console.log((ok ? "  OK " : "  FAIL") + " " + status + "  " + name);
  });
  const passed = results.filter((x) => x.ok).length;
  const total = results.length;
  console.log("\nTotal: " + passed + "/" + total + " passed");

  server.close();
  process.exit(passed === total ? 0 : 1);
}

run().catch((err) => {
  console.error("Error:", err.message);
  if (server) server.close();
  process.exit(1);
});
