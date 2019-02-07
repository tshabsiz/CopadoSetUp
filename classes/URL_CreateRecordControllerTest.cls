@IsTest
private class URL_CreateRecordControllerTest {

    @IsTest
    private static void test_get_field_describe() {

        Test.startTest();

        Map<String, Object> fieldDescribeMap = URL_CreateRecordController.getFieldDescribeMap( 'Account' );

        System.debug( fieldDescribeMap );

        System.assertEquals( true, ( (Map<String, Object>) fieldDescribeMap.get( 'Name' ) ).get( 'createable' ) );
        System.assertEquals( false, ( (Map<String, Object>) fieldDescribeMap.get( 'Id' ) ).get( 'updateable' ) );

        Test.stopTest();

    }

}