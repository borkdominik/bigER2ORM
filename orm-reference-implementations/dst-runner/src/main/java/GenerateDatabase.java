import javax.persistence.EntityManagerFactory;
import javax.persistence.Persistence;

public class GenerateDatabase {
    public static void main(String[] args) {
        System.out.println("Starting DST Reference Database Schema Generator...");
        try {
            EntityManagerFactory emf = Persistence.createEntityManagerFactory("dst_reference_pu");
            System.out.println("SUCCESS: DST Reference Database Schema generated cleanly in PostgreSQL (dst_reference)!");
            emf.close();
            System.exit(0);
        } catch (Exception e) {
            System.err.println("ERROR: Failed to generate DST Reference Database schema:");
            e.printStackTrace();
            System.exit(1);
        }
    }
}
