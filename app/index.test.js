import { app, server } from ".";
import request from "supertest";
import User from "./users/model.js";
import sequelize from "./shared/database/database";
import { Sequelize } from "sequelize";

describe("API Tests", () => {
    let data;
    let mockedSequelize;

    beforeEach(async () => {
        data = {
            dni: "1234567890",
            name: "Test",
        };
        jest.spyOn(console, "log").mockImplementation(jest.fn());
        jest.spyOn(console, "error").mockImplementation(jest.fn());
        jest.spyOn(sequelize, "log").mockImplementation(jest.fn());
        mockedSequelize = new Sequelize({
            database: "<any name>",
            dialect: "sqlite",
            username: "root",
            password: "",
            validateOnly: true,
            models: [__dirname + "/models"],
        });
        await mockedSequelize.sync({ force: true });
    });

    afterEach(async () => {
        jest.clearAllMocks();
        await mockedSequelize.close();
    });

    afterAll(async () => {
        if (server) {
            server.close();
        }
    });

    describe("Health Endpoint", () => {
        test("Should return healthy status when database is connected", async () => {
            jest.spyOn(sequelize, "authenticate").mockResolvedValue(true);
            const response = await request(app).get("/health");

            expect(response.status).toBe(200);
            expect(response.body.status).toBe("healthy");
            expect(response.body.database).toBe("connected");
            expect(response.body.timestamp).toBeDefined();
        });

        test("Should return unhealthy status when database is disconnected", async () => {
            const mockError = new Error("Connection refused");
            jest.spyOn(sequelize, "authenticate").mockRejectedValue(mockError);
            const response = await request(app).get("/health");

            expect(response.status).toBe(500);
            expect(response.body.status).toBe("unhealthy");
            expect(response.body.database).toBe("disconnected");
            expect(response.body.error).toBe("Connection refused");
            expect(response.body.timestamp).toBeDefined();
        });
    });

    describe("User Endpoints", () => {
        test("Get users", async () => {
            jest.spyOn(User, "findAll").mockResolvedValue([data]);
            const response = await request(app).get("/api/users");

            expect(response.status).toBe(200);
            expect(response.body).toEqual([data]);
        });

        test("Get users - handle database error", async () => {
            jest.spyOn(User, "findAll").mockRejectedValue(
                new Error("Database error")
            );
            const response = await request(app).get("/api/users");

            expect(response.status).toBe(500);
            expect(response.body.error).toBe("Internal Server Error");
        });

        test("Get user", async () => {
            jest.spyOn(User, "findByPk").mockResolvedValue({ ...data, id: 1 });
            const response = await request(app).get("/api/users/1");

            expect(response.status).toBe(200);
            expect(response.body).toEqual({ ...data, id: 1 });
        });

        test("Get user - user not found", async () => {
            jest.spyOn(User, "findByPk").mockResolvedValue(null);
            const response = await request(app).get("/api/users/999");

            expect(response.status).toBe(404);
            expect(response.body.error).toBe("User not found: 999");
        });

        test("Get user - handle database error", async () => {
            jest.spyOn(User, "findByPk").mockRejectedValue(
                new Error("Database error")
            );
            const response = await request(app).get("/api/users/1");

            expect(response.status).toBe(500);
            expect(response.body.error).toBe("Internal Server Error");
        });

        test("Create user", async () => {
            jest.spyOn(User, "findOne").mockResolvedValue(null);
            jest.spyOn(User, "create").mockResolvedValue({ ...data, id: 1 });
            const response = await request(app).post("/api/users").send(data);

            expect(response.status).toBe(201);
            expect(response.body).toEqual({ ...data, id: 1 });
        });

        test("Create user - user already exists", async () => {
            jest.spyOn(User, "findOne").mockResolvedValue({ ...data, id: 1 });
            const response = await request(app).post("/api/users").send(data);

            expect(response.status).toBe(400);
            expect(response.body.error).toBe("User already exists: 1234567890");
        });

        test("Create user - handle database error", async () => {
            jest.spyOn(User, "findOne").mockRejectedValue(
                new Error("Database error")
            );
            const response = await request(app).post("/api/users").send(data);

            expect(response.status).toBe(500);
            expect(response.body.error).toBe("Internal Server Error");
        });

        test("Create user - invalid data validation", async () => {
            const invalidData = { dni: "123", name: "" };
            const response = await request(app)
                .post("/api/users")
                .send(invalidData);

            expect(response.status).toBe(400);
        });
    });
});
