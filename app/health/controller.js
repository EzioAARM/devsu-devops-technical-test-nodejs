import sequelize from '../shared/database/database.js'

export const healthCheck = async (req, res) => {
    try {
        // Test database connection
        await sequelize.authenticate()

        res.status(200).json({
            status: 'healthy',
            database: 'connected',
            timestamp: new Date().toISOString(),
        })
    } catch (error) {
        console.error('Database connection failed:', error)

        res.status(500).json({
            status: 'unhealthy',
            database: 'disconnected',
            error: error.message,
            timestamp: new Date().toISOString(),
        })
    }
}
